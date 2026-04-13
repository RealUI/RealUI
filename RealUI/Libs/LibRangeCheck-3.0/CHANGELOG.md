# Lib: RangeCheck-3.0

## [1.0.17-10-ga6b43e6](https://github.com/WeakAuras/LibRangeCheck-3.0/tree/a6b43e614b018f0121fadcb51c5bd7933b40bf52) (2026-04-09)
[Full Changelog](https://github.com/WeakAuras/LibRangeCheck-3.0/compare/1.0.17...a6b43e614b018f0121fadcb51c5bd7933b40bf52) [Previous Releases](https://github.com/WeakAuras/LibRangeCheck-3.0/releases)

- Fix: Titan event registration and use C\_EventUtils.IsEventValid  
    Titan no longer has the LEARNED\_SPELL\_IN\_TAB event  
    Switched to C\_EventUtils.IsEventValid across all expansions to prevent lua errors on titan and future lua errors  
    Fixed CVAR\_UPDATE registration  
    TOC Bumps  
- - Adding Pyroblast as fallback for Mages  
- Remove "Ring of righteous Flame" as reportely it's affected by talents  
    Fixes: #45  
- Add TBC and Wrath support and bump TOC files  
    Added new TOC files for The Burning Crusade and Wrath of the Lich King Classic. Updated Interface versions and metadata in existing TOC files. Modified core library logic to detect TBC and adjust event registration accordingly.  
- Switch to unitID caching for Midnight  
- Disable range caching for Midnight due to secrets  
- - Basic support for Midnight (no spell changes)  
- Add Black Arrow for Dark Ranger Hunter.  
    Dar Ranger hero talent "Bleak Arrows" will unlearn Auto Shot not provide any replacement spell. Black Arrow can be used instead, as it is learned with DR.  
- Add new items (#39)  
    * Add new debug function for checking items  
    * Sourced from builds 1.15.5.57807, 4.4.1.57564, 11.0.7.57788  
- Prist: Add Mind Flay for Vanilla Classic (#41)  
    Fixes: #40  