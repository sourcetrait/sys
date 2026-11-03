SourceTrait SysBox
================================================================================
[![License Badge]][License]

An isolated Fedora system in a box (Podman container).

Usage
--------------------------------------------------------------------------------

Shell scripts mentioned here are in:
- Bash 5: `./shell/bash/*.bash`
- PowerShell 7: `./shell/pwsh/*.ps1`

Use the `once` script to setup shortcuts and build the container image:
- Linux / Macos: `./shell/bash/once.bash`
- Windows: `./shell/pwsh/once.ps1`


Use the `create <hostname> <ssh_key>` script to create a new container.

Use the `login <hostname>` script to enter a container's terminal.


Repository
--------------------------------------------------------------------------------

Found a bug?  
Let us know! Upvote an existing issue or create one if not found.

Have questions, concerns, ideas, or requests?  
Upvote an existing discussion or create one if not found.

### Branches
- `release` (default) Stable
- `dev` Unstable

### Contributors
Contributors, please review [SOURCETRAIT.md](./SOURCETRAIT.md).  

#### Copyright Assignment Agreement (CAA)
By committing to this repository you
[agree to assign](./docs/legal/Copyright_Assignment_Agreement.md)
to [Asmov LLC](https://asmov.software)
all right, title, and interest worldwide in all copyright covering your
contribution.


License (AGPL3)
--------------------------------------------------------------------------------
SourceTrait SysBox  
Developed by [SourceTrait](https://sourcetrait.com), a division of **Asmov LLC**  
Copyright (C) 2026 [Asmov LLC](https://asmov.software)  

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a [copy](./LICENSE-AGPL-3.txt) of the
GNU Affero General Public License along with this program.
If not, see https://www.gnu.org/licenses/.


[Docs Badge]: https://img.shields.io/badge/docs-blue
[License]: #License-AGPL3
[License Badge]: https://img.shields.io/badge/license-AGPL3-blue.svg
