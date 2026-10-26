# Aliens Attack — cool, important, weird, and hidden things

This is the plain-English version. No code knowledge needed.

Aliens Attack is internally called **`g1019`** and **“CreepyAliens.”** It is a wave-defense shooter: you and other players protect a base, kill aliens, earn money and EXP, buy better guns and armor, and try to survive as many waves as possible.

I went through every available version, all the map files, all the gun and monster tables, and the decrypted game code. These are the most interesting things hiding in it.

---

## 1. “Hard mode” is a real separate place, not a button

There is no “Hard Mode” switch, menu, or unlock popup in the game files.

What players call hard mode is actually a **second map** called `m1019_10`.

- Normal map: **100 waves**
- Hard map: **60 waves**
- Hard map starts at wave 1, not after beating normal
- Hard map has different terrain
- Hard map was added in **version 10110** (around July 2025)
- It is still the same in the latest version, v10113

The game files never say “hard mode.” The label comes from players, because the second map is much harder.

### Does it unlock at level 30, 60, or 100?

Not in the game files.

There is **no level requirement, kill requirement, wave requirement, or unlock flag** for that map anywhere in the Aliens Attack package. The game does not choose the map at all. A server outside the game chooses which map to send you to.

So:

- **No, you do not need account level 687.**
- **No, you do not need to reach wave 60.**
- **No, you do not need to beat normal first.**
- The game simply receives a map from the server before the match starts.

If there is a real unlock rule, it lives on the server, not in the game files we have.

---

## 2. What makes hard mode hard

At first glance it sounds easier: 60 waves instead of 100. It is not.

| Thing | Normal map | Hard map |
|---|---:|---:|
| Waves | 100 | 60 |
| Aliens on screen at once | 30 | 33 |
| Time per wave | 190 seconds | 310 seconds |
| Alien spawn bursts | 10 | 15 |
| Player starting attack | 300 | 450 |
| Player starting defense | 300 | 330 |
| Player health regen | 0 | 10 |
| Heal when player levels up | 10% | 15% |
| Heal when base upgrades | 20% | 33% |
| Alien types | 20 | 32 |
| Boss types | 2 | 3 |
| Final base health | 70,000 | 138,750 |

Hard mode is shorter, but each wave is much heavier. The total alien health is about **2.44× normal**, and the last wave alone has about **11.5×** the health of the normal final wave.

### Bosses every 10 waves

Hard mode has boss fights at waves **10, 20, 30, 40, 50, and 60**.

By the time you reach the final boss, you have killed **7,986 aliens**.

The final wave has:

- **258 kills required**
- one brand-new boss: **`3031`**
- **600,000 HP**
- **99,999 attack**
- two extra mini-bosses
- three more mini-bosses
- **252 small but dangerous demons**

The new boss is a giant octopus-like alien. It is by far the biggest enemy in the game.

### The secret money waves

Some hard-mode waves are unusually generous:

- wave 17: 150 kills, 9,000 gold
- wave 19: 180 kills, 12,000 gold
- wave 37: 150 kills, 15,000 gold
- wave 39: 180 kills, 18,000 gold
- waves 57–59: 240 kills and 5,000 gold each

These are the best places to farm gold if you can survive them.

---

## 3. The giant hard-mode boss is not a normal enemy

Boss `3031` is a massive jump over every other boss:

- Normal bosses: 16,000–30,000 HP
- Hard boss `3031`: **600,000 HP**
- Its attack is **99,999**
- It gives 60,000 gold and 5,000 EXP

The normal final wave is almost funny by comparison: only **4 kills**. The hard final wave is 258 kills and a 600,000-HP boss.

There is also a not-yet-live version of the hard map in the latest files. In that test version, the final base has **3,700,000 HP**, and the final boss is weaker but much faster. That version is called `m1019_2` and is **not live** — it is a preview of a future rebalance.

---

## 4. Normal mode has a secret “oops” in the first levels

The normal map’s data says:

- wave 1 needs 40 kills
- wave 21 needs 75 kills
- wave 25 needs 69 kills

But those waves do not actually spawn that many aliens.

The game quietly lowers the requirement to the number that can spawn:

- wave 1: 40 → **15**
- wave 21: 75 → **61**
- wave 25: 69 → **61**

So the first wave is much shorter than the data claims. It is a small built-in bug that makes early normal mode easier.

Hard mode does not have this problem. Every hard wave spawns exactly as many aliens as it asks you to kill.

---

## 5. The normal map never got new content

All 41 available versions contain the same normal map data:

- 100 waves
- 20 alien types
- 2 bosses
- 30 gun levels
- 4 armor slots
- 100 base upgrades
- same terrain

Later updates changed the game engine, UI, events, anti-cheat, and packaging, but not the normal-mode gameplay data.

The only real new gameplay content in the whole history is the **hard map**.

---

## 6. Weird weapon secret: level 28 is completely different

Weapon level 28 is the strange one.

- Normal map: **1 pellet per shot**, very fast
- Hard map: **6 pellets per shot**, slower
- Future hard map: **3 pellets per shot**

That is why hard mode’s level-28 gun suddenly does a huge amount of damage. It is not just a stat increase; it changes from a single bullet to a shotgun-style blast.

Another oddity: from gun level 14 onward, the hard-mode gun list uses different item/model IDs than normal. It looks like the list was shifted by one row. The damage numbers still follow the level, but the gun model you see may not match what you expect.

---

## 7. Hidden and unused map areas

Every map file contains **three scene files**:

- `scene1.yml`
- `scene2.yml`
- `scene3.yml`

But the game only ever loads **scene1**.

That means two complete sets of alien spawn points are sitting unused in every map. They are leftovers, not secret rooms.

- normal scene2: about 23 spawn points
- normal scene3: about 6 spawn points
- boss spawn points also exist in those unused scenes

You cannot reach them in normal play.

---

## 8. Hidden or unused aliens

Normal mode has 20 alien definitions, but only 18 actually appear.

One alien, **`1022`**, is defined but never spawned in normal mode. Hard mode does use it.

Hard mode adds 12 alien types that normal mode never uses, including:

- a tower-targeting green alien
- a fragile but extremely high-damage charging alien
- new demon variants
- new rabbit, bat, and angel variants
- the giant final boss

So hard mode is not just “normal mode with bigger numbers.” It has its own enemy roster.

---

## 9. The level cap is much higher than the EXP table

The game allows players to reach **level 1000**.

But the special EXP curve only covers levels **1–30**.

After level 30, every level costs the same **1,000 EXP**. There is no unique curve for levels 31–1000; it just repeats.

That means late-game leveling becomes very predictable, and the “max level” is mostly a giant number rather than a fully designed progression.

---

## 10. Leaderboard oddity

In v10113, the weekly leaderboard has a bug:

- it is supposed to expire weekly
- it actually expires **daily**
- the “daily” level leaderboard has no date in its key, so it can behave like an all-time board instead

This is visible in the code, not just a guess.

---

## 11. Developer tools are real, but not for normal players

The game contains a large **GM / developer panel** and a local debug console.

These can do things like:

- give items
- change movement speed
- fly
- teleport
- spawn AI players
- force-start the game
- close the server
- clear databases

In the normal live game these are test-gated or admin-gated. The production server also auto-kicks certain GM messages. They are development leftovers, not a secret player feature.

I am intentionally not giving instructions for using them.

---

## 12. Lots of “extra game” code is sitting unused

The package contains code for many features that Aliens Attack does not actually turn on, including:

- lottery / blind-box activities
- daily check-in
- gift triggers
- video ads and rewards
- voice packs
- chat bubbles
- translation tools
- VIP banner/pendant cosmetics
- old paid event systems

Only a few are enabled, and the paid events are expired — their active dates were in **2022–2023**. In the 2026 version, the event code is still there but has nothing live to show.

This is why the game can look “empty” of events even though the files are full of event code.

---

## 13. The 687.9 number is not a requirement

You may have seen “required player level 687.9” in the charts. This causes a lot of confusion.

It does **not** mean:

- you need account level 687
- you need level 687 to unlock hard mode
- every player must be level 687

It means this:

> If one player fights alone, never misses, fights one alien at a time, has every gun, and has to kill the final hard wave within 310 seconds, the math says their **in-match level** would need to be about 687.9 to have just enough damage.

The simulated in-match level after all the EXP from that run is **678**. That leaves the damage just barely short — about **99.5%** of what the simple model wants.

Real games are different:

- other players help
- armor helps
- you move and dodge
- you do not need to kill every alien the instant it spawns
- you can use better positioning
- splash damage and multi-target shots are not in the model

So the 687.9 is a **math warning**, not a gate.

---

## 14. Quick “wow” numbers

- 41 available versions in the archive
- 5 version numbers are missing from the capture
- 30 gun tiers per map
- 4 armor slots: helmet, chest, legs, boots
- 20 alien types on normal, 32 on hard
- Normal: 100 waves, 8,112 effective kills
- Hard: 60 waves, 7,986 kills
- Hard final wave: 258 kills, 600,000-HP boss
- Normal final wave: 4 kills
- Hard final base: 138,750 HP
- Future staging final base: 3,700,000 HP
- Every weapon costs **6,403,500 gold** total
- Max level: 1,000
- After level 30, every level costs 1,000 EXP

---

## 15. The biggest myths

| Claim | Truth |
|---|---|
| “Hard mode unlocks at level 30/60/100.” | No unlock exists in the game files. |
| “Hard mode starts after 60 waves.” | No. It is a separate map that starts at wave 1. |
| “Hard mode is a button in the menu.” | No official button or label exists. |
| “You need level 687 for hard mode.” | No. 687.9 is a solo math estimate, not a requirement. |
| “Normal mode got new waves later.” | No. Normal gameplay data is unchanged across all versions. |
| “The extra scenes are secret bonus maps.” | No. They are unused leftovers. |
| “The developer panel is a secret player cheat.” | It is a test/admin tool, not a normal feature. |

---

## Where the proof is

- Hard map levels and boss gates: `reports\agents\hard_mode\REPORT.md`
- Gun charts and tables: `v10113\charts\`
- Hidden and unused content: `reports\agents\features\HIDDEN_FEATURES.md`
- Full timeline: `reports\agents\features\FEATURE_TIMELINE.md`
- All versions and extraction: `decrypted\all_versions\` and `reports\agents\extraction\REPORT.md`
- Balance data and charts: `reports\agents\data\DATA_MODEL.md` and `reports\agents\data\CHARTS\`

No production game files, GitHub files, or live services were modified.
