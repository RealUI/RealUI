**Changes in 9.0.2:**

- _Rainrider (3):_
    1. core: unregister the event when unit validation fails
    2. core: do not use table.remove as it alters the index which also breaks the loop in the __call meta method
    3. core: keep the event table even with one handler left
- 2 files changed, 12 insertions(+), 17 deletions(-)

**Changes in 9.0.1:**

- _Rainrider (1):_
    1. Update toc interface and a happy new year everyone
- 2 files changed, 5 insertions(+), 5 deletions(-)

