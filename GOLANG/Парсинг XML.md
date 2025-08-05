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

}

  

byteData, _ := ioutil.ReadAll(data)

dataset := &Dataset{}

xml.Unmarshal(byteData, dataset)

  

fmt.Println("Hello 21", dataset)

}
```