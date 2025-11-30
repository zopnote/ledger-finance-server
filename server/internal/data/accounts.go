package data

import (
	"log"
	"os"

	"gopkg.in/yaml.v3"
)

type BalanceType int

const (
	passive BalanceType = iota
	active
	yield
)

var balanceMap = map[BalanceType]string{
	passive: "passive",
	active:  "active",
	yield:   "yield",
}

type Account struct {
	AccountNumber int         `yaml:"id"`
	Description   string      `yaml:"name"`
	Category      BalanceType `yaml:"type"`
}
type accountFile struct {
	Accounts []Account `yaml:"accounts"`
}

func RetrieveAccounts() []Account {

	yamlFile, err := os.ReadFile("config/accounts.yaml")
	if err != nil {
		log.Printf("yamlFile.Get err  #%v ", err)
	}
	var accountFile = &accountFile{}
	err = yaml.Unmarshal(yamlFile, accountFile)
	if err != nil {
		log.Fatalf("Unmarshal: %v", err)
	}

	return accountFile.Accounts
}
