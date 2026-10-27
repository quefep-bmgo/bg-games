import sys, struct, zipfile, json
sys.stdout.reconfigure(encoding='utf-8', errors='replace')
from elftools.elf.elffile import ELFFile
from elftools.elf.relocation import RelocationSection
from capstone import Cs, CS_ARCH_ARM64, CS_MODE_LITTLE_ENDIAN
from capstone.arm64 import ARM64_OP_MEM, ARM64_OP_REG
from unicorn import Uc, UC_ARCH_ARM64, UC_MODE_ARM, UcError, UC_HOOK_CODE
from unicorn.arm64_const import (UC_ARM64_REG_X0, UC_ARM64_REG_X1, UC_ARM64_REG_X2,
                                 UC_ARM64_REG_X8, UC_ARM64_REG_LR, UC_ARM64_REG_SP,
                                 UC_ARM64_REG_PC, UC_ARM64_REG_TPIDR_EL0, UC_ARM64_REG_CPACR_EL1)

BASE = r'C:\Users\quefep\AppData\Local\Temp\opencode\g1042_analysis'
SO = rf'{BASE}\native\bg_libBlockMan_arm64.so'
elf = ELFFile(open(SO, 'rb'))
SP = 0x70000000
SC = 0x30000000
HEAP = 0x50000000
BUF_IN = SC + 0x1000
CTX = SC + 0x200
DATA_STR = SC + 0x300
KEY_STR = SC + 0x320
OUT_STR = SC + 0x340
KEYBUF = SC + 0x100

md = Cs(CS_ARCH_ARM64, CS_MODE_LITTLE_ENDIAN)
md.detail = True

def build_plt_map():
    plt = elf.get_section_by_name('.plt')
    paddr = plt['sh_addr']
    pdata = plt.data()
    relocs = {}
    dynsym = elf.get_section_by_name('.dynsym')
    for s in elf.iter_sections():
        if isinstance(s, RelocationSection):
            for r in s.iter_relocations():
                off = r['r_offset']
                name = None
                try:
                    name = dynsym.get_symbol(r['r_info_sym']).name
                except Exception:
                    pass
                if name:
                    relocs.setdefault(off, set()).add(name)
    out = {}
    for off in range(0, len(pdata) - 16 + 1, 16):
        code = pdata[off:off + 16]
        insns = list(md.disasm(code, paddr + off))
        if len(insns) < 4:
            continue
        i0, i1, i2, i3 = insns[:4]
        if (i0.mnemonic == 'adrp' and i1.mnemonic == 'ldr' and i2.mnemonic in ('add', 'nop')
                and i3.mnemonic == 'br'):
            page = i0.operands[1].imm
            slot = None
            if i1.operands[1].type == ARM64_OP_MEM and i1.operands[1].mem.base == i0.operands[0].reg:
                slot = page + i1.operands[1].mem.disp
            if slot in relocs:
                out[paddr + off] = sorted(relocs[slot])[0]
    return out

PLT = build_plt_map()
print(f'PLT stubs resolved: {len(PLT)}')

class Hooks:
    def __init__(self):
        self.ptr = HEAP
        self.log = []
        self.bad = set()

    def alloc(self, uc, ln):
        ln = (max(ln & 0xffffffff, 0x40) + 15) & ~15
        p = self.ptr
        self.ptr += ln + 16
        uc.mem_write(p, b'\x00' * ln)
        return p

def str_info(uc, obj):
    flag = uc.mem_read(obj, 1)[0]
    if flag & 1:
        ln = struct.unpack('<Q', bytes(uc.mem_read(obj + 8, 8)))[0]
        ptr = struct.unpack('<Q', bytes(uc.mem_read(obj + 0x10, 8)))[0]
    else:
        ln = flag >> 1
        ptr = obj + 1
    return ln, ptr

def sset_str(uc, h, obj, data):
    data = data[:0x100000]
    buf = h.alloc(uc, len(data) + 1)
    uc.mem_write(buf, data + b'\x00')
    uc.mem_write(obj, b'\x01')
    uc.mem_write(obj + 8, struct.pack('<Q', len(data)))
    uc.mem_write(obj + 0x10, struct.pack('<Q', buf))

def make_uc():
    me = Uc(UC_ARCH_ARM64, UC_MODE_ARM)
    for seg in elf.iter_segments():
        if seg['p_type'] != 'PT_LOAD':
            continue
        va, memsz = seg['p_vaddr'], seg['p_memsz']
        data = seg.data()
        b, e = va & ~0xfff, (va + memsz + 0xfff) & ~0xfff
        try:
            me.mem_map(b, e - b)
        except UcError:
            pass
        if data:
            me.mem_write(va, data)
    for s in elf.iter_sections():
        if not isinstance(s, RelocationSection):
            continue
        for r in s.iter_relocations():
            if r['r_info_type'] == 1027:
                me.mem_write(r['r_offset'], struct.pack('<Q', r['r_addend'] & 0xffffffffffffffff))
    me.mem_map(SP - 0x10000, 0x20000)
    me.mem_map(SC, 0x10000)
    me.mem_map(HEAP, 0x10000000)
    me.reg_write(UC_ARM64_REG_TPIDR_EL0, 0x1000)
    me.reg_write(UC_ARM64_REG_SP, SP)
    try:
        me.reg_write(UC_ARM64_REG_CPACR_EL1, 0x300000)
    except Exception:
        pass
    h = Hooks()

    def rd(uc, addr, n):
        return bytes(uc.mem_read(addr & 0xffffffffffffffff, n))

    def hook(uc, address, size, ud):
        name = PLT.get(address)
        if name is not None:
            lr = uc.reg_read(UC_ARM64_REG_LR)
            x0 = uc.reg_read(UC_ARM64_REG_X0)
            x1 = uc.reg_read(UC_ARM64_REG_X1)
            x2 = uc.reg_read(UC_ARM64_REG_X2)
            if name in ('memcpy', 'memmove', '__memcpy_chk', '__memmove_chk'):
                n = x2 & 0xffffffffffffffff
                src = rd(uc, x1, n)
                uc.mem_write(x0, src)
                uc.reg_write(UC_ARM64_REG_X0, x0)
            elif name in ('memset', '__memset_chk'):
                n = x2 & 0xffffffffffffffff
                uc.mem_write(x0, bytes([x1 & 0xff]) * n)
                uc.reg_write(UC_ARM64_REG_X0, x0)
            elif name == 'strlen':
                s = b''
                p = x0
                while True:
                    c = rd(uc, p, 64)
                    z = c.find(b'\x00')
                    if z >= 0:
                        s += c[:z]
                        break
                    s += c
                    p += 64
                uc.reg_write(UC_ARM64_REG_X0, len(s))
            elif name in ('memcmp', 'bcmp', '__memcmp_chk'):
                n = x2
                a = rd(uc, x0, n)
                b_ = rd(uc, x1, n)
                res = 0
                for i in range(n):
                    if a[i] != b_[i]:
                        res = 1 if a[i] > b_[i] else -1
                        break
                uc.reg_write(UC_ARM64_REG_X0, res & 0xffffffffffffffff)
            elif name == '_ZNSt6__ndk112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE6appendEmc':
                ln, ptr = str_info(uc, x0)
                sset_str(uc, h, x0, rd(uc, ptr, ln) + bytes([x2 & 0xff]) * (x1 & 0xffffffffffffffff))
                uc.reg_write(UC_ARM64_REG_X0, x0)
            elif name == '_ZNSt6__ndk112basic_stringIcNS_11char_traitsIcEENS_9allocatorIcEEE7reserveEm':
                uc.reg_write(UC_ARM64_REG_X0, x0)
            elif name in ('strcmp', 'strncmp', '__strcmp_chk', '__strncmp_chk'):
                n = x2 if name in ('strncmp', '__strncmp_chk') else 0x1000
                a = rd(uc, x0, n).split(b'\x00')[0]
                b_ = rd(uc, x1, n).split(b'\x00')[0]
                res = (a > b_) - (a < b_)
                uc.reg_write(UC_ARM64_REG_X0, res & 0xffffffffffffffff)
            elif name in ('malloc', 'calloc', 'realloc', 'operator new', 'operator new[]',
                          '_Znwm', '_Znam', '_Znwj', '_Znaj'):
                if name == 'calloc':
                    p = h.alloc(uc, x0 * x1)
                elif name == 'realloc':
                    p = h.alloc(uc, x1)
                else:
                    p = h.alloc(uc, x0)
                uc.reg_write(UC_ARM64_REG_X0, p)
            elif name in ('free', 'cfree', 'operator delete', 'operator delete[]',
                          '_ZdlPv', '_ZdaPv', '__cxa_free_exception'):
                uc.reg_write(UC_ARM64_REG_X0, 0)
            elif name in ('memchr',):
                n = x2
                data = rd(uc, x0, n)
                idx = data.find(bytes([x1 & 0xff]))
                uc.reg_write(UC_ARM64_REG_X0, (x0 + idx) if idx >= 0 else 0)
            elif name in ('abort', '__stack_chk_fail', '__assert2'):
                h.bad.add(name)
                uc.reg_write(UC_ARM64_REG_PC, 0)
                return
            else:
                if name not in h.bad:
                    h.bad.add(name)
                uc.reg_write(UC_ARM64_REG_X0, 0)
            uc.reg_write(UC_ARM64_REG_PC, lr)
            return
        if address == 0x1f348d0 or address == 0x1f349e4 or address == 0x1f35134:
            return
        if address in (0x1ded3a0, 0x1ded39c, 0x1de687c):
            uc.reg_write(UC_ARM64_REG_X0, h.alloc(uc, uc.reg_read(UC_ARM64_REG_X0)))
            uc.reg_write(UC_ARM64_REG_PC, uc.reg_read(UC_ARM64_REG_LR))
            return
        if address == 0x1de690c:
            if (uc.reg_read(UC_ARM64_REG_X0) & 0xffffffff) < 0x100000:
                uc.reg_write(UC_ARM64_REG_X0, h.alloc(uc, uc.reg_read(UC_ARM64_REG_X0)))
            uc.reg_write(UC_ARM64_REG_PC, uc.reg_read(UC_ARM64_REG_LR))
            return
        if address in (0x1ded3a8, 0x1ded3a4, 0x1de68cc, 0x1de6950):
            uc.reg_write(UC_ARM64_REG_PC, uc.reg_read(UC_ARM64_REG_LR))
            return
    me.hook_add(UC_HOOK_CODE, hook)
    return me, h

def decrypt(data, key, mode=0):
    me, h = make_uc()
    me.mem_write(CTX, b'\x00' * 0x200)
    me.reg_write(UC_ARM64_REG_X0, CTX)
    me.reg_write(UC_ARM64_REG_X1, mode)
    me.reg_write(UC_ARM64_REG_LR, 0)
    try:
        me.emu_start(0x1f348d0, 0, count=1000)
    except UcError:
        pass
    for a in (DATA_STR, KEY_STR, OUT_STR):
        me.mem_write(a, b'\x00' * 0x20)
    me.mem_write(BUF_IN, data)
    me.mem_write(KEYBUF, key)
    me.mem_write(DATA_STR, struct.pack('<B7xQ', 1, len(data)) + struct.pack('<Q', BUF_IN))
    me.mem_write(KEY_STR, struct.pack('<B7xQ', 1, len(key)) + struct.pack('<Q', KEYBUF))
    me.reg_write(UC_ARM64_REG_X0, CTX)
    me.reg_write(UC_ARM64_REG_X1, DATA_STR)
    me.reg_write(UC_ARM64_REG_X2, KEY_STR)
    me.reg_write(UC_ARM64_REG_X8, OUT_STR)
    me.reg_write(UC_ARM64_REG_SP, SP)
    me.reg_write(UC_ARM64_REG_LR, 0)
    try:
        me.emu_start(0x1f35acc, 0, count=50000000)
    except UcError:
        pass
    b0 = me.mem_read(OUT_STR, 1)[0]
    if b0 & 1:
        ln = struct.unpack('<Q', bytes(me.mem_read(OUT_STR + 8, 8)))[0]
        ptr = struct.unpack('<Q', bytes(me.mem_read(OUT_STR + 16, 8)))[0]
        out = bytes(me.mem_read(ptr, ln)) if ln < 0x1000000 else b''
    else:
        out = bytes(me.mem_read(OUT_STR + 1, b0 >> 1))
    return out, h.bad

if __name__ == '__main__':
    pack = open(rf'{BASE}\native\bgmap_engine_res.pack', 'rb').read()
    ln1 = struct.unpack('<I', pack[:4])[0]
    blob1 = pack[4:4 + ln1]
    out, bad = decrypt(blob1, b'blrsp20241212345')
    print('blob1 out:', out, 'bad:', bad)
