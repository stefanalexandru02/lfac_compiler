#include <stdio.h>
#include <stdlib.h>
#include <string.h>


extern int yylineno;
struct dataType {
        char * id_name;
        char * data_type;
        char * type;
        int line_no;
        void * value;
} symbol_table[4000];                                          
int count=0;

struct function_signature_parameter { 
      char* function_id;
      char* function_type;
      char * id;
      char * type;
} function_definition_symbol_table[4000];  
int function_definition_table_count = 0;

struct temp_function_definition_data {
      char* type;
      char* id;
} temp_function_definition_table[100];    
int temp_function_definition_cnt = 0;

struct dynamic_variable_values_data {
    char* id;
    char* value;
} dynamic_variable_values_table[1000];
int dynamic_variable_values_cnt = 0;

void print_symbol_table()
{
    remove("symbol_table.txt");
    FILE *fptr = fopen("symbol_table.txt","w");
    fprintf(fptr, "SYMBOL   DATATYPE    TYPE       LINE NUMBER    DEFAULT VALUE\n");
    for(int i = 0 ; i < count; i++)
    {
        if(strcmp(symbol_table[i].type, "Function") == 0) continue; //TODO THIS SHOULD BE ENABLED

        if(symbol_table[i].value)
        {
            if(strcmp(symbol_table[i].data_type, "int") == 0)
            {
                fprintf(fptr,"%s\t     %s\t     %s\t     %d\t     %s\t     \n", symbol_table[i].id_name, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].line_no, symbol_table[i].value);
            }
            else if(strcmp(symbol_table[i].data_type, "char") == 0)
            {
                fprintf(fptr,"%s\t     %s\t     %s\t     %d\t     %c\t     \n", symbol_table[i].id_name, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].line_no, symbol_table[i].value);
            }
            else if(strcmp(symbol_table[i].data_type, "float") == 0)
            {
                fprintf(fptr,"%s\t     %s\t     %s\t     %d\t     %s\t     \n", symbol_table[i].id_name, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].line_no, symbol_table[i].value);
            }
            else if(strcmp(symbol_table[i].data_type, "char[]") == 0 || strcmp(symbol_table[i].data_type, "bool[]") == 0)
            {
                fprintf(fptr,"%s\t     %s\t     %s\t     %d\t     %s\t     \n", symbol_table[i].id_name, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].line_no, symbol_table[i].value);
            }
            else if(strcmp(symbol_table[i].data_type, "int[]") == 0 || strcmp(symbol_table[i].data_type, "float[]") == 0)
            {
                fprintf(fptr,"%s\t     %s\t     %s\t     %d\t     %s\t     \n", symbol_table[i].id_name, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].line_no, symbol_table[i].value);
            }
            else if(strcmp(symbol_table[i].data_type, "bool") == 0)
            {
                fprintf(fptr,"%s\t     %s\t     %s\t     %d\t     %s\t     \n", symbol_table[i].id_name, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].line_no, symbol_table[i].value);
            }
            else{
                fprintf(fptr,"%s\t     %s\t     %s\t     %d\t     %s\t     \n", symbol_table[i].id_name, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].line_no, "TYPE NOT SUPPORTED");
            }
        } else {
            fprintf(fptr,"%s\t     %s\t     %s\t     %d\t     %s\t     \n", symbol_table[i].id_name, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].line_no, "-");    
        }
    }
    fclose(fptr);
}
void print_function_symbol_table()
{
    remove("symbol_table_functions.txt");
    FILE *fptr = fopen("symbol_table_functions.txt","w");
    fprintf(fptr, "SYMBOL           TYPE        PARAM TYPE    PARAM ID\n");
    char functionName[1000] = {0};
    for(int i = 0 ; i < function_definition_table_count; i++)
    {
        if(strcmp(functionName, function_definition_symbol_table[i].function_id) != 0)
        {
            strcpy(functionName, function_definition_symbol_table[i].function_id);
            fprintf(fptr, "______________________________________________________\n\n");
        }
        fprintf(fptr,"%s\t     %s\t     %s\t       %s\t\n", 
            function_definition_symbol_table[i].function_id,
            function_definition_symbol_table[i].function_type,
            function_definition_symbol_table[i].type,
            function_definition_symbol_table[i].id);
    }
    fclose(fptr);
}

int has_semantic_analysis_errors = 0;
void validateAbstractExpressionTypes(const char* type1, const char* type2)
{
    // printf("Validating expression types %s, %s\n", type1, type2);
    if(strcmp(type1, type2) != 0)
    {
        has_semantic_analysis_errors = 1;
        printf("Type conversion not allowed on line %d between %s and %s\n", yylineno, type1, type2);
    }
}

const char* convertIntToChar(int value, char * str)
{
    sprintf(str, "%d", value);
    return str;
}
const char* convertFloatToChar(float value, char * str)
{
    sprintf(str, "%.6f", value);
    return str;
}

const char* calculateAbstractExpressionStrValue(const char* type, char op, const char* value1, const char* value2)
{
    char *str = (char*)malloc(10);
    if(strcmp(type, "int") == 0)
    {
        int _value1 = atoi(value1);
        int _value2 = atoi(value2);

        int _result = 0;
        switch (op)
        {
            case '+':
                _result = _value1 + _value2;
                break;
            case '-':
                _result = _value1 - _value2;
                break;
            case '*':
                _result = _value1 * _value2;
                break;
            case '/':
                _result = _value1 / _value2;
                break;
            default:
                break;
        }
        convertIntToChar(_result, str);
        return str;
    }
    if(strcmp(type, "float") == 0)
    {
        float _value1 = atof(value1+1);
        float _value2 = atof(value2+1);

        float _result = 0;
        switch (op)
        {
            case '+':
                _result = _value1 + _value2;
                break;
            case '-':
                _result = _value1 - _value2;
                break;
            case '*':
                _result = _value1 * _value2;
                break;
            case '/':
                _result = _value1 / _value2;
                break;
            default:
                break;
        }
        convertFloatToChar(_result, str);
        return str;
    }
    return "N/A";
}