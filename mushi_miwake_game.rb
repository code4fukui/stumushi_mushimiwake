#usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'csv'
require 'io/console'
require 'io/console/size'
require 'timeout'
puts("虫見分けゲーム!")
puts("\n虫の写真が表示されます。")
puts("\nその虫が外来種か絶滅危惧種か固有種か見分けて、矢印キーで写真を移動させてそれぞれの箱に入れてください。")
puts("\n正しい箱に入れられたら+1ptです。")
puts("\n虫は全部で22匹用意されていて、出てくる虫はその中の5匹です。")
puts("\n実行するウィンドウはmltermで、なるべく大きくしておきましょう。")
puts("\n準備はいいですか?(Enter)")
print(">>")
gets
def byouga(y,box,r_mushi,a,tate,yoko,quiznum)
  system("clear")
  print("\e[1;1H")
  printf("\e[30;47m<%d種類目> %s[%s]\n\e[m",quiznum,r_mushi["和名"],r_mushi["学名"])
  (tate/64*49-1).times{print((" "*(a+1))*3," \n")}
  print("\e[#{tate/64*49};1H")
  (tate/64*16-2).times{print(("@"+" "*(a))*3,"@\n")}
  puts("@"*(3*a+4))
  print("\e[#{tate/64*65-2};#{a*0+2}H\e[34;47m外来種\e[#{tate/64*65-2};#{a*1+3}H絶滅危惧種\e[#{tate/64*65-2};#{a*2+4}H固有種\e[m")#tate/64*49-1+tate/64*16-2+1=tate/64*65-2
  print("\e[#{tate/64*65-1};1H<説明>\n",r_mushi["説明"])
  print("\e[#{y*1+2};#{box*a+2+box}H")
  system("img2sixel #{r_mushi["写真"]}")
end
def kekka(box,seikai,a,r_mushi,point)
  system("clear")
  print("\e[1;1H<結果発表!!>\n")
  sleep(1)
  printf("\e[47m%s\e[m\n",box==seikai ? "\e[31m正解!" : "\e[34m不正解…" )
  system("img2sixel #{box==seikai ? "mark_maru.png" : "mark_batsu.png" }")
  print("\e[2;46H#{r_mushi["和名"]}[#{r_mushi["学名"]}]は#{r_mushi["状態"]}でした。\e[4;46H")
  system("img2sixel #{r_mushi["写真"]}")
  puts("\e[37;1H<説明>\n#{r_mushi["説明"]}")
  puts("<分布地域画像>")
  system("img2sixel #{r_mushi["分布地域画像"]}")
  puts("灰色…絶滅\n赤色…絶滅危惧I類\nオレンジ…絶滅危惧II類\n黄色…準絶滅危惧種\n水色…情報不足") if r_mushi["状態番号"]=="1"
  print("説明文は#{r_mushi["説明出典"]}\n写真は#{r_mushi["画像出典"]}(横のpxが300になるようにアスペクト比を変えずに拡大・縮小しました。)")
  puts("\n現在のポイント:#{point}pt")
  return (box==seikai ? 1 : 0 )
end
mushi=CSV.read("虫データ.csv",:headers => true)
mushi_num=Array.new(mushi.length){|n| n }
tate,yoko=IO::console_size
a=(yoko-1)/4-1
point=0
quiznum=1
syu=22-5
while mushi_num.length>syu
  r=rand(mushi_num.length)
  r_mushi=mushi[mushi_num[r]]
  y=0
  box=0 #0:外来種,1:絶滅危惧種,2:固有種
  while true
    byouga(y,box,r_mushi,a,tate,yoko,quiznum)
    break if y==tate/64*65-2-r_mushi["写真サイズ"].to_i-2
    begin
      Timeout.timeout(0.5){
        key=STDIN.getch
        if key=="\e"&&STDIN.getch=="["
          key=STDIN.getch
          if key=="B" #↓
            break if y==tate/64*65-2-r_mushi["写真サイズ"].to_i-2
            y+=1
          elsif key=="C" #→
            if box==2
            else
              box+=1
            end
          elsif key=="D" #←
            if box==0
            else
              box-=1
            end
          end
        elsif key=="\C-c"
          exit
        end
      }
    rescue Timeout::Error
      y+=1
    end
  end
  sleep(0.5)
  mushi_num.delete_at(r)
  point+=kekka(box,r_mushi["状態番号"].to_i,a,r_mushi,point)
  quiznum=mushi.length-mushi_num.length+1
  print(mushi_num.length>syu ? "次の問題に行きますか?(yes:Enter no(中断):Ctrl+c)\n>>" : "結果のページを開きますか?\n>>")
  gets
end
kekka_html=File.read("kekka.html")
file="m_m_game_kekka.html"
open(file, "w") {|html| html.print kekka_html.gsub("_point_", point.to_s)}
system("firefox m_m_game_kekka.html")
