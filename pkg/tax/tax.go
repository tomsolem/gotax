package tax

import (
	"errors"
	"strconv"
)

type TableInput struct {
	TableCount  int // 4 digits
	PeriodCount int // 1 digit
	TypeCount   int // 1 digit
	Salary      int // 5 digits
	Tax         int // 5 digits

}

func convert(str string) (*TableInput, error) {
	if len(str) != 16 {
		return &TableInput{}, errors.New("invalid length on string")
	}

	result := TableInput{}
	res, err := toInt(str[0:4])
	if err != nil {
		return &TableInput{}, errors.New("invalid length on string")
	}
	result.TableCount = res

	res, err = toInt(str[4:5])
	if err != nil {
		return &TableInput{}, errors.New("invalid length on string")
	}
	result.PeriodCount = res

	res, err = toInt(str[5:6])
	if err != nil {
		return &TableInput{}, errors.New("invalid length on string")
	}
	result.TypeCount = res

	res, err = toInt(str[6:11])
	if err != nil {
		return &TableInput{}, errors.New("invalid length on string")
	}
	result.Salary = res

	res, err = toInt(str[11:16])
	if err != nil {
		return &TableInput{}, errors.New("invalid length on string")
	}
	result.Tax = res

	return &result, nil
}

func toInt(ts string) (int, error) {
	ti, err := strconv.ParseInt(ts, 10, 32)
	if err != nil {
		return -1, errors.New("invalid length on string")
	}
	res := int(ti)
	return res, nil
}
