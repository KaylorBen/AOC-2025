static bool CheckRoll(string[] lines, int col, int row)
{
   int count = 0;
   for (int i = -1; i <= 1; i++)
      for (int k = -1; k <= 1; k++)
      {
         if (i == 0 && k == 0) continue;
         try
         {
            if (lines[col-i][row-k] == '@')
               count++;
         }
         catch
         {
            continue;
         }
      }
   return (count < 4);
}

using StreamReader reader = new("input");
string text = reader.ReadToEnd();
string[] lines = text.Split('\n');
int sum = 0;
for (int i = 0; i < lines.Length; i++)
   for (int k = 0; k < lines[i].Length; k++)
      if (lines[i][k] == '@')
         if (CheckRoll(lines, i, k))
            sum++;
Console.WriteLine(sum);
