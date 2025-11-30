package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

var statusCmd = &cobra.Command{
	Use:   "status",
	Short: "Shows the status of the server",
	Long:  "Displays several information about the status of the paths server and it's data.",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Hello world")
	},
}
