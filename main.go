package main

import (
	"fmt"

	"golang.org/x/crypto/bcrypt"
)

func main() {

	// for cost := 1; cost <= 10; cost++ {
	// 	res, err := bcrypt.GenerateFromPassword([]byte("welcome2021."), cost)
	// 	if err != nil {
	// 		fmt.Println(err)
	// 	} else {
	// 		fmt.Println(string(res[:]))
	// 	}
	// }
	data := [...]string{
		"$2a$10$/ndnZSgCkoUkzblFsIcgu.1SRJHmyx.zmC2JHA3j/sIrWxZftoRVO",
		"$2a$10$lHUnDMimnDUGIcrkT6nZQeDqQtqQJeVNwXcRG2.xSCApnat05zNg6",
		"$2a$10$U9b6af1w16k.IaeUT78g4eDvAYRYyWoPJkP8N9zxG/z3qUFl0G442",
		"$2a$04$mEkRz2OOy6o0DLEaYpwF4u9154hK5F5fegABoEPReR09noFy17vjW",
		"$2a$05$bTdqy7IScB7WVJXRUs0G7.8lRWHl3wo4NkfsgT2/cwglKQwPnlAre",
		"$2a$06$GEc71xItRJhI4/hPvJc0P.ceI4/D.02f6VGN.3uUaeL5YA84oCui6",
		"$2a$07$vTSuD9bnZcD/CYWG9fCWBuwh/NQAzBXAmu7oeGyA/OPZCx4eWbACS",
		"$2a$08$XuVw0ftAMdN7hGo6UpVRFu51sURpy7PshsaBbwUbBnwYKkVGiBLuK",
		"$2a$09$rn.oz/E3kVWL3EWZlziMo.P2lfZoDGBSgDn/oH71RWmGjl7LtS.XO",
		"$2a$10$qJ7USD7kqcPyiOeuOz9k5uMfGgkByyG1Bg7VFhQ4A.wYdxop0uvSa",
	}

	for cost := 0; cost < 10; cost++ {
		if checkString(data[cost], "welcome2021.") {
			fmt.Println(cost)
		}
	}
}

func checkString(sa, inp string) bool {
	return bcrypt.CompareHashAndPassword([]byte(sa), []byte(inp)) == nil
}
