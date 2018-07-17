#Function test
#To be run in CMD:
#example
#Rscript commandine_test.R "hi lola" 456

#Function
printer <- function(input1,input2=2) 
{
  tryCatch({
    print(input1)
    print(input2)
  })
}

#Call function
args <- commandArgs(TRUE)
printer(args[1],args[2])