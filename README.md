# APB-Protocol-Project-
APB master with two slaves that does read and write operation

Schematic of this project can be seen in the following figure:
![](https://github.com/WazaAbdulkadir/APB-Protocol-Project-/blob/main/image/yongatek%20.png)

In this project there are 1 APB Master and 2 APB slaves.

We are reading data from slave 1 ,and add 10 to this data in the master. Then we write sum of the operation -new data- to the slave 2.

I have used 9 bit address. I used 9th bit as slave select. When 9th bit is 1 slave_1 is selected else slave_2 is selected.


