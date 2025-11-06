function(target) |||
    Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
    Upstream-Name: %(target)s
    Source: https://github.com/radxa-pkg/%(target)s

    Files: [git submodules]
    License: External Code

    Files: debian/patches/**/*.patch
    License: External Code Patch

    Files: *
    Copyright: © 2025 Radxa Computer Co., Ltd
    License: GPL-3+

    License: External Code
     Unless otherwise specified, they are subject to the relevant License within
     the submodule repo.

    License: External Code Patch
     Unless otherwise specified, they share the same license to the code being
     patched.

    License: GPL-3+
     This program is free software; you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published by
     the Free Software Foundation; either version 3, or (at your option)
     any later version.
     .
     This program is distributed in the hope that it will be useful, but
     WITHOUT ANY WARRANTY; without even the implied warranty of
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
     General Public License for more details.
     .
     You should have received a copy of the GNU General Public License
     along with this program.  If not, see <https://www.gnu.org/licenses/>.
     .
     On Debian systems, the complete text of the GNU General Public License
     can be found in /usr/share/common-licenses/GPL-3.
||| % {
    target: target,
}