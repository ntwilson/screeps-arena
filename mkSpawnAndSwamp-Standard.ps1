$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

npx spago bundle --module SpawnAndSwamp.StandardStrategy

$contents = Get-Content -Raw .\index.js

$prefix = @"
import { prototypes, utils, constants } from 'game';

export function loop() {
"@

$suffix = "}"

$main = $prefix + "`n" + $contents + "`n" + $suffix

Set-Content -Path ~\ScreepsArena\beta-spawn_and_swamp\main.mjs -Value $main
