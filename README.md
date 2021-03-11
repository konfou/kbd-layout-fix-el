This is an Emacs adaption of https://github.com/konfou/kbd-layout-fix

It provides a function that maps  between two layouts defined in another
function.  As  explained in aforementioned  repo, to enter text  in some
languages  a  special key  combination  is  required.  This  solves  the
problem that  one writes  in one  language when they  meant to  write in
another.   By  selecting the  text  and  running  function the  text  is
modified to the correct one.

As predefined  example the mapping  between English and Greek  layout is
provided, along a  wrapper function showing how can one  make a function
that  can be  binded for  interactive usage.   For example,  if one  has
written *Ιτ ςασ α δαρκ ανδ στορμυ νιγητ* it will replace it with *It was
a  dark and  stormy night*.   If  one has  written *Mia  for;a ki  ;enan
kair;o*, it will replace it with *Μια φορά κι έναν καιρό*.
