$csharp = @"
using System;
namespace HelloWorld
{
    public class Program
    {
        public static void Main(){
            Console.WriteLine("Hello World!");
            }
        }
    }

"@
iex "[HelloWorld.Program]::Main()"

add-type -Language CSharpVersion3 -TypeDefinition $CSharp
