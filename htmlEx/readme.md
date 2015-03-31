# htmlEx
コメント内に配置した命令で比較的簡単に動的ページを作るCGIツールです。  
目指した所はよりシンプルなphpでした。

当時は頑張って作りましたが相当ひどいので実用には適しません。  
今ならXMLの適当な名前空間を命令と解釈する形にすると思います。

index.cgiは一部正常に動作しません。

##文法
文法は以下の感じです。
```
<!-- COMMAND VAR CALENDAR YEAR -->
```
このように``<!-- COMMAND コマンド 引数-->``のようにすると命令が実行できます。  
変数は名前空間毎に個別の変数がある二階層になっています。

```
<!-- COMMAND BEGIN DATABASE 0 ./info.csv INFO -->
{title} : {comment} @ {date}<br />
<!-- COMMAND END INFO -->
```
このように<!-- COMMAND BEGIN 命令 WORD --><!-- COMMAND END WORD -->形式でhtmlを引数とした命令を記述できます。  
上はCSV形式のファイルを一行ずつ展開する命令になります。

複数行の命令はPROGRAMで示せます。
```
<!-- COMMAND BEGIN PROGRAM HEAD -->
SET PAGEINFO PAGECNT (FORM PAGE) 1
<!-- COMMAND END HEAD -->
```
これで変数PAGECNTの内容がhttpのフォームデータ"PAGE"の値に設定されます。初期値は1になります。  
()内には命令を記せます。
