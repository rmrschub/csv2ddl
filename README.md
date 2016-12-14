# csv2ddl
csv2ddl is a REST API for generating SQL DDL statements from tabular data in several delimiter-spearated value formats.

You can use csv2ddl in order to create DDL statements like
```sql
CREATE TABLE LegoColorMap (
  hex_code TEXT NOT NULL PRIMARY KEY,
  Brick_Owl TEXT,
  Lego_Name TEXT,
  Lego INTEGER,
  LDraw INTEGER,
  Peeron TEXT,
  BL TEXT
)
```
from tabular data like

| hex code | Brick Owl    | Lego Name          | Lego | LDraw | Peeron  | BL           | 
|----------|--------------|--------------------|------|-------|---------|--------------| 
| b5d3d6   | Aqua         | LIGHT BLUISH GREEN | 118  | 118   | Aqua    | Aqua         | 
| 0057a6   | Blue         | BR. BLUE           | 23   | 1     | Blue    | Blue         | 
| 0057a6   | Blue         | BR.BLUE            | 23   | 1     | Blue    | Blue         | 
| 0057a6   | Blue         | BRIGHT BLUE        | 23   | 1     | Blue    | Blue         | 
| 10cb31   | Bright Green | BR.GREEN           | 37   | 10    | BtGreen | Bright Green | 

# Usage
Get csv2ddl up and running. HTTP GET requests can be made against csv2ddl's form-style GET API as follows
```
GET csv2ddl?fileUri={uri}&tableName={name}&delimiter={delim} HTTP/1.1
Server: http://HOST:8080
```
where `uri` is the URI of a delimiter-separated file, `name` is table name of your choice and `delim` is the file's delimiter symbol.

Need some examples? The following request 
```
GET csv2ddl?fileURI=https://raw.githubusercontent.com/rmrschub/csv2ddl/master/horror/test.csv&tableName=ColorMap&delimiter=; HTTP/1.1
Server: http://HOST:8080
```
will give you the following SQL DDL
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


## Docker Setup
 Build Docker container and run csv2ddl 
```{r, engine='bash', count_lines}
docker build -t csv2ddl .
docker run -ti --rm -p 8080:8080 csv2ddl
````

## Contributions
Contributions are very welcome.

## Third-party Contents
This source distribution includes the third-party items with respective licenses as listed in the THIRD-PARTY file found in the top-level directory of this distribution.

## License
csv2ddl is subject to the license terms in the LICENSE file found in the top-level directory of this distribution. 
You may not use this file except in compliance with the License.

## Open Issues
* Encoding bullshit...
* tab-separated files not supported yet