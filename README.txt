使用環境linux ubuntu 64bit

---用lex跟yacc簡單的直譯器---
功能
1. 可宣告變數
2. 四則運算
3. 可以if
4. 可以lambdafunction
5. 定義named fuction

lex檔的部分---------------------------
我把 數字return NUMBER
我把 #t #freturn BOOL
以及其他人為定義的字串先回傳我想要的值
最後把ID的部分return回去，
而空格跟換行忽略掉。
剩下的字元為非法字元會輸出unexpected character字樣
--------------------------------------

yacc檔的部分--------------------------
所有的exp我都用存到一個binary tree裡面

tree的node都會有一個type記錄他是哪個operater或是number或是variable，
如果是number，他的value就會記錄他的值;如果是variable，他的name就會記住他的名字
1.遇到一個operation時他的規則就是(op exp exps) 或 (op exp) 就把左右小孩放成左右exp存的tree，自己就是op
2.單純遇到ID時就自己是variable，左右小孩為空
3.單純遇到NUMBER時就自己是number，左右小孩為空
4.有些exps可以展開，我將它們分成不同operator的exp，就可以根據不同的operator創造node
5.最後每個獨立exp的exp都會變成一個tree
6.直到需要那個exp的值時，我才會call EvalueTree(exp)，的方式算出值，用簡單的DFS就可以算出來了。

儲存變數的方式新的變數ID進來時，我就給他一個va[vsp]的其中一個vsp的位子
在def_stmt時，會有我會exp的值算出來，以及順便把exp存在該名字裡面，以備之後使用該名字。
當我有名字時，我用get_vsp(ID)就可以知道他的vsp。

if的部分就是會先算出test_exp的值，在選擇要將then_exp或else_exp傳下去，最後就看他的造化了。

在function的部分，如果沒有parameter，我的fun_exp就還是把我那個exp傳下去，
如果有，就把進去tree內，把對應變數的地方都換成對應的parameter，
如果是fun_name的部分，我就去va[vsp]，找到對應的exp，再根據有沒有parameter做對應的處理

error的部分我自己寫了error的function，告訴使用者error的東西是哪個，
在每個operation的定義中，也寫了如果少了exp的error就可以判斷出來了
--------------------------------------
