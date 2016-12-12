# csv2ddl

A bash script for dealing with tabular data in several formats, guessing types and detecting headers.

csv2ddl creates DDL statements like this
```sql
CREATE TABLE ColorMap (
  hex_code TEXT NOT NULL PRIMARY KEY,
  Brick_Owl TEXT,
  Lego_Name TEXT,
  Lego INTEGER,
  LDraw INTEGER,
  Peeron TEXT,
  BL TEXT
)
```

from stuff like that

|----------|--------------|--------------------|------|-------|---------|--------------| 
| hex code | Brick Owl    | Lego Name          | Lego | LDraw | Peeron  | BL           | 
| b5d3d6   | Aqua         | LIGHT BLUISH GREEN | 118  | 118   | Aqua    | Aqua         | 
| 0057a6   | Blue         | BR. BLUE           | 23   | 1     | Blue    | Blue         | 
| 0057a6   | Blue         | BR.BLUE            | 23   | 1     | Blue    | Blue         | 
| 0057a6   | Blue         | BRIGHT BLUE        | 23   | 1     | Blue    | Blue         | 
| 10cb31   | Bright Green | BR.GREEN           | 37   | 10    | BtGreen | Bright Green | 
|----------|--------------|--------------------|------|-------|---------|--------------|


## Usage
Make sure to use Bash 4.+!

```{r, engine='bash', count_lines}
chmod +x csv2ddl.sh
./csv2ddl.sh [INPUT_FILE] [TABLE_NAME] [HEADER_LINE] [PK_COLUMN] [DELIMITER] > [OUTPUT_FILE]
```

## Contributions
Contributions are very welcome.

## Third-party Contents
This source distribution includes the third-party items with respective licenses as listed in the THIRD-PARTY file found in the top-level directory of this distribution.

## License
csv2ddl is subject to the license terms in the LICENSE file found in the top-level directory of this distribution. 
You may not use this file except in compliance with the License.
