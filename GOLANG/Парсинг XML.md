```xml
<?xml version="1.0" encoding="UTF-8" ?>
<root>
	<row>
		<id>0</id>
		<guid>1a6fa827-62f1-45f6-b579-aaead2b47169</guid>
		<isActive>false</isActive>
		<balance>$2,144.93</balance>
		<picture>http://placehold.it/32x32</picture>
		<age>22</age>
		<eyeColor>green</eyeColor>
		<first_name>Boyd</first_name>
		<last_name>Wolf</last_name>
		<gender>male</gender>
		<company>HOPELI</company>
		<email>boydwolf@hopeli.com</email>
		<phone>+1 (956) 593-2402</phone>
		<address>586 Winthrop Street, Edneyville, Mississippi, 9555</address>
		<about>Nulla cillum enim voluptate consequat laborum esse excepteur occaecat commodo nostrud excepteur ut cupidatat. Occaecat minim incididunt ut proident ad sint nostrud ad laborum sint pariatur. Ut nulla commodo dolore officia. Consequat anim eiusmod amet commodo eiusmod deserunt culpa. Ea sit dolore nostrud cillum proident nisi mollit est Lorem pariatur. Lorem aute officia deserunt dolor nisi aliqua consequat nulla nostrud ipsum irure id deserunt dolore. Minim reprehenderit nulla exercitation labore ipsum.
		</about>
		<registered>2017-02-05T06:23:27 -03:00</registered>
		<favoriteFruit>apple</favoriteFruit>
	</row>
	<row>
		<id>1</id>
		<guid>46c06b5e-dd08-4e26-bf85-b15d280e5e07</guid>
		<isActive>false</isActive>
		<balance>$2,705.71</balance>
		<picture>http://placehold.it/32x32</picture>
		<age>21</age>
		<eyeColor>green</eyeColor>
		<first_name>Hilda</first_name>
		<last_name>Mayer</last_name>
		<gender>female</gender>
		<company>QUINTITY</company>
		<email>hildamayer@quintity.com</email>
		<phone>+1 (932) 421-2117</phone>
		<address>311 Friel Place, Loyalhanna, Kansas, 6845</address>
		<about>Sit commodo consectetur minim amet ex. Elit aute mollit fugiat labore sint ipsum dolor cupidatat qui reprehenderit. Eu nisi in exercitation culpa sint aliqua nulla nulla proident eu. Nisi reprehenderit anim cupidatat dolor incididunt laboris mollit magna commodo ex. Cupidatat sit id aliqua amet nisi et voluptate voluptate commodo ex eiusmod et nulla velit.
		</about>
		<registered>2016-11-20T04:40:07 -03:00</registered>
		<favoriteFruit>banana</favoriteFruit>
	</row>
</root>
```

```go
package main

import (
	"encoding/xml"
	"fmt"
	"io/ioutil"
	"os"
)

type Dataset struct {
	Root xml.Name `xml:"root"`
	Row []struct {
		Id string `xml:"id"`
		Guid string `xml:"guid"`
		IsActive bool `xml:"isActive"`
		Balance string `xml:"balance"`
		Picture string `xml:"picture"`
		Age int `xml:"age"`
		EyeColor string `xml:"eyeColor"`
		First_name string `xml:"first_name"`
		Last_name string `xml:"last_name"`
		Gender string `xml:"gender"`
		Company string `xml:"company"`
		Email string `xml:"email"`
		Phone string `xml:"phone"`
		Address string `xml:"address"`
		About string `xml:"about"`
		Registered string `xml:"registered"`
		FavoriteFruit string `xml:"favoriteFruit"`
	} `xml:"row"`
}

func main() {
	data, err := os.Open("dataset.xml")
	if err != nil {
		fmt.Println(err)
		return
	}

	byteData, _ := ioutil.ReadAll(data)
	dataset := &Dataset{}
	xml.Unmarshal(byteData, dataset)

	fmt.Println(dataset)
}
```