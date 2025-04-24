# pw-o-matic

**pw-o-matic** is an optimized password generator script written in Bash. It allows users to generate secure passwords tailored to specific environments and requirements with ease of customization.

## Features

- Generates secure passwords optimized for different environments, at the time being:
  - Linux
  - Oracle
  - PowerShell
- Avoids special symbol characters that may be misinterpreted on the specified environment.
- Supports variable or fixed password lengths.
- Allows defining the number of passwords to generate.
- The major parameters can be tuned for your requirements in almost one place of block in the script.

## Requirements

- [apg](https://github.com/jabenninghoff/apg) (Automated Password Generator)

## How It Works

1. **Password Generation**:
   - Relies on `apg` to generate passwords.
   - Tailors password options based on the chosen environment (`-f` flavor).

2. **Optimization**:
   - By utilizing the functionality of `apg`, it is possible to generate passwords consist of phrases that are not in the dictionary but pronounceable, i.e. just barely memorable.
   - Filters unsafe symbols for specific environments.
   - Ensures passwords are secure and compliant with environment constraints.

3. **Warnings**:
   - Provides cautionary messages for additional security considerations.

## Usage

Run the script with the following options:

```bash
./pw-o-matic.sh [-f FLAVOR] [-n NUM_OF_OUTPUT] [-l PW_LENGTH] [-w]
```

### Options:
- `-f`: Optimization flavor (Optional)
  - Supports `linux`, `oracle`, or `powershell`.
  - Default: Only minimal general optimizations.
- `-n`: Number of passwords to generate (Optional)
  - Default: 3.
- `-l`: Length of each password (Optional)
  - Must be >= 4.
  - Default: Variable length based on the chosen flavor.
- `-w`: Suppress cautionary messages (Optional).

### Examples:

#### Example 1:
Generate 2 general-purpose passwords:
```bash
$ ./pw-o-matic.sh -n 2
No optimization applied
COMMAND : "apg -a 0 -n 2 -t -m 13 -x 16 -M SNCL -E \\"
Acyimcaggun(oc0 (Ac-yim-cagg-un-LEFT_PARENTHESIS-oc-ZERO)
vecZoftUg!in6 (vec-Zoft-Ug-EXCLAMATION_POINT-in-SIX)
```

#### Example 2:
Generate Linux-optimized passwords with a fixed length of 13:
```bash
$ ./pw-o-matic.sh -f linux -l 13
Optimized for linux
COMMAND : "apg -a 0 -n 3 -t -m 13 -x 13 -M SNCL -E !\"$&\'()*,-.;<>[\]^`{|}~"
8_dravBunawp8 (EIGHT-UNDERSCORE-drav-Bun-awp-EIGHT)
@DroccuOcWas7 (AT_SIGN-Droc-cu-Oc-Was-SEVEN)
TetIp8ophyeg@ (Tet-Ip-EIGHT-oph-yeg-AT_SIGN)
```

#### Example 3:
Generate Oracle-optimized passwords:
```bash
$ ./pw-o-matic.sh -f oracle
Optimized for oracle
COMMAND : "apg -a 0 -n 3 -t -m 10 -x 14 -M sNCL -E !\"#$%&\'()*+,-./:;<=>?@[\]`{|}~"
GrazIvyasEed_9 (NINE-Graz-Iv-yas-Eed-UNDERSCORE) [Pronunciation may not match password.]
IfurheyQuiof0 (If-ur-hey-Qui-of-ZERO)
KredthuvEtOn7 (Kredth-uv-Et-On-SEVEN)
```

## Note on apg

The `apg` program, used as a dependency for this script, was originally authored by Adel I. Mirzazhanov. Its project home page was [http://www.adel.nursat.kz/apg/](http://www.adel.nursat.kz/apg/), but sadly, the project went offline.

As a reliable alternative, the GitHub repository [`jabenninghoff/apg`](https://github.com/jabenninghoff/apg.git) serves as a trusted fork of the original `apg`.

## License

This script is open-source and available under the MIT License.

---

Happy password generating!
