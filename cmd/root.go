package cmd

import (
	"os"

	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:   "ledge-fs",
	Short: "A backend server with the purpose of ledgement.",
	Long: "A ledger server for storing, managing and processing financial data about td-services." +
		" The website is available under https://www.tdls-del.de",
}

func Execute() {
	err := rootCmd.Execute()
	if err != nil {
		os.Exit(1)
	}
}

func init() {
	rootCmd.CompletionOptions.DisableDefaultCmd = true
	rootCmd.AddCommand(statusCmd)
}
