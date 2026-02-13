package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"

	"github.com/loft-sh/vcluster/pkg/util/translate"
)

type TestCase struct {
	ResourceName string `json:"resource_name"`
	Namespace    string `json:"namespace"`
	VclusterName string `json:"vcluster_name"`
	UpdatedName  string `json:"updated_name"`
}

func main() {
	file, err := os.Open("test_cases.json")
	if err != nil {
		log.Fatalf("failed to open test_cases.json: %v", err)
	}
	defer file.Close()

	bytes, err := ioutil.ReadAll(file)
	if err != nil {
		log.Fatalf("failed to read test_cases.json: %v", err)
	}

	var testCases []TestCase
	err = json.Unmarshal(bytes, &testCases)
	if err != nil {
		log.Fatalf("failed to unmarshal test cases: %v", err)
	}

	for i, tc := range testCases {
		expectedName := translate.SingleNamespacePhysicalName(tc.ResourceName, tc.Namespace, tc.VclusterName)
		testCases[i].UpdatedName = expectedName
	}

	output, err := json.MarshalIndent(testCases, "", "  ")
	if err != nil {
		log.Fatalf("failed to marshal test cases: %v", err)
	}

	fmt.Println(string(output))
}
