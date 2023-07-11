
template <typename T>
void AppendElement(T &arr[], T &element)
{
    int arrSize = ArraySize(arr);
    ArrayResize(arr, arrSize + 1);
    arr[arrSize] = element;
}
template <typename T>
void EraseElement(T &arr[], int pos)
{
    int arrSize = ArraySize(arr);
    if(pos > arrSize - 1 || pos < 0) 
    {
        Print("Error function EraseElement: tried to access array out of bound");
        return;
    }
    for (int i = pos; i < arrSize - pos + 1; i++)
    {
        if(arrSize == 1)
            break;
        else
            arr[i] = arr[i+1];
    }
    ArrayResize(arr, arrSize-1);
}

template <typename T>
void InsertElement(T &arr[],T &element, int pos)
{
    int arrSize = ArraySize(arr);

    if(pos > arrSize || pos < 0) 
    {
        Print("Error function InserElement: tried to access array out of bound");
        return;
    }
    ArrayResize(arr, arrSize+1);
    int newArrSize = ArraySize(arr);
    for (int i = newArrSize - 1; i > pos; i--)
    {
        // if(pos == newArrSize - 1)
        //     break;
        // else
            arr[i] = arr[i-1];
    }
    arr[pos] = element;
}

template <typename T>
void PrintArray(T &arr[])
{
   for(int i = 0; i < ArraySize(arr); i++)
   {
        Print("Array[" + string(i) + "] = " + string(arr[i]));
   }
}