package tax

import (
	"bufio"
	"fmt"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
)

func Test_Convert_String_to_struct(t *testing.T) {
	str := "7105101990003016"
	expected := TableInput{
		TableCount:  7105,
		PeriodCount: 1,
		TypeCount:   0,
		Salary:      19900,
		Tax:         3016,
	}

	result, err := convert(str)
	assert.NoError(t, err, "error converting string")
	assert.Equal(t, expected.TableCount, result.TableCount, "invalid table count")
	assert.Equal(t, expected.PeriodCount, result.PeriodCount, "invalid period count")
	assert.Equal(t, expected.TypeCount, result.TypeCount, "invalid type count")
	assert.Equal(t, expected.Salary, result.Salary, "invalid salary count")
	assert.Equal(t, expected.Tax, result.Tax, "invalid tax count")
}

func Test_read_tax_file(t *testing.T) {

	file, err := os.Open("../../data/2020/sample.txt")
	assert.NoError(t, err, "error reading file")
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		txt := scanner.Text()
		in, err := convert(txt)
		assert.NoError(t, err, "error converting string to tax struct")
		fmt.Printf("income: %d, tax: %d \n", in.Salary, in.Tax)
	}
}
