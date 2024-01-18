module Test

public str Test = "form taxOfficeExample
{ 
  \"Did you buy a house in 2010?\"
    hasBoughtHouse: boolean
    
  \"Did you enter a loan?\"
    hasMaintLoan: boolean
    
  \"Did you sell a house in 2010?\"
    hasSoldHouse: boolean = 3 && \"aaa\"

  if (1) {
  } else {
    {
      \"Did you sell a house in 2010?\"
        hasSoldHouse: boolean = 3
    }
  }
   
}";
