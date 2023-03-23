#!/usr/bin/gawk -f

## Readme.
## This script automatically builds html-file with icons in a Context-directory of Icon Theme.
## It requires GAWK (GNU Awk scripting language -- not POSIX-awk, mawk or nawk!).
## To use this script, make it executable (chmod +x table_grassmunk.awk), then run it in a context folder, for example:
### [user@computer places]$ table_grassmunk.awk > places.html
## It will create a HTML-file with table of found icons Grassmunk's decoration.
## The structure of theme MUST be as:
### Theme/Context/Size/icon.png
### For example: SE98/places/48/user-desktop.png
## (NOT ThemeName/places/48X48/user-desktop.png
## and NOT ThemeName/48X48/places/user-desktop.png
## and NOT ThemeName/48/places/user-desktop.png)

@load "readdir"
@load "filefuncs"

function capital(word){ #Make first letter capital
return toupper(substr(word,1,1)) tolower(substr(word,2,length(word)))
}

function iconames(dirar,iconarr,lnarr,	i,pwdi,lnfil){ #Get all names of .png icons in this context
	for(i in dirar){
#split("",lnarr)
		pwdi=ENVIRON["PWD"]"/"i
		fs=FS
		FS="/"
		while((getline<pwdi)>0){
			if($3~/(f|l)/&&$2~/\.(pn|sv)g$/)(all_iconar[$2])
			if($3~"f"&&$2~/\.png$/){gsub(/\.[^.]*$/,"",$2);iconarr[$2];dirnam=i"/"$2;existar[dirnam]=dirnam}
			if($3~"l"&&$2~/\.png$/){
				#split("",lnarr)
				#split("",lnarr[$2])
				lnfil=pwdi"/"$2
				stat(lnfil, statdata)
				gsub(/\.[^.]*$/,"",$2) # "folder.png" >> "folder"
				#lnmem=i"/"$2
				lnarr[$2][i]=statdata["linkval"] # lnarr["inode-directory"][48]="folder"
				dirlnam=i"/"$2 # dirlnam="48/inode-directory"
				existlnar[dirlnam]=dirlnam # existlnar["48/inode-directory"]="48/inode-directory"
			}
		}
		FS=fs
	}
}

function prepare(){ #Define html variables and get size folders.
fol_nam=ENVIRON["PWD"]
gsub(/^.*\//,"",fol_nam)
fs=FS
FS="/"
while((getline<ENVIRON["PWD"])>0){
if($3=="d"&&$2!~/^\.+$/&&$2*1<=256){if($2~/[0-9]+/){dirar[$2]};dirar_a[$2]} #$2~/[0-9]+/ -- dirar_a -- массив со ВСЕМИ папками (в том числе совсем левыми).
}
FS=fs

head="<!DOCTYPE html>\n\
<!-- Generated by this GAWK script: https://github.com/nestoris/scripts-for-Icon-theming/blob/main/table_grassmunk.awk -->\n\
<html>\n\
<head>\n\
<style>\n\
td {\n\
  border: 1px solid black;\n\
  padding: 1px;\n\
  text-align:center;\n\
  font-size: x-small;\n\
  vertical-align: bottom;\n\
  background: repeating-linear-gradient(\n\
    -45deg,\n\
    #fff 0 5px,\n\
    #f9f9f9 5px 10px\n\
  );\n\
}\n\
td.empty {\n\
  background: repeating-linear-gradient(\n\
    -45deg,\n\
    #cdd 0 5px,\n\
    #acc 5px 10px);\n\
  border: 1px solid #666666;\n\
}\n\
td.ln {\n\
  border: 1px solid #808080;\n\
  background: repeating-linear-gradient(\n\
    -45deg,\n\
    #f3f3f3 0 5px,\n\
    #e6e6e6 5px 10px\n\
  );\n\
}\n\
table {\n\
  position: relative;\n\
  margin-left: auto;\n\
  margin-right: auto;\n\
}\n\
\n\
th {\n\
  background: #000080;\n\
  color: white;\n\
  position: sticky;\n\
  top: 0;\n\
  border: 1px solid black;\n\
  padding: 1px;\n\
  text-align:center;\n\
}\n\
\n\
body {\n\
  background: #008080;\n\
  font-family: Arial, Helvetica, Arial, sans-serif;\n\
}\n\
h1, h2 {\n\
  font-family: Arial, Helvetica, Arial, sans-serif;\n\
  color: white;\n\
  text-align:center;\n\
  font-weight: bold;\n\
}\n\
</style>\n\
<title>SE98 Icons: "capital(fol_nam)"</title>\n\
<!-- Part of the SE98 project -->\n\
</head>\n\
<body><h1>SE98 Icons: "capital(fol_nam)"</h1>\n\
<br><br>\n\
<center><p style=\"color:white\">Below is the list of all icons using in the <b>"capital(fol_nam)"</b> section. Each icon is identified by its name. Symlinks are belower, they have links to the originals on this page.</p></center>\n\
<br><br>"
foot="</body></html>"

}

function readsizes_md(sizes_md,sizes_md_a,sizes_md_u_a, # файл-список, массив по порядку, массив уникальных размеров
						imd,k){
min_s=1000000
max_s=0
while((getline<sizes_md)>0){gsub("#.*$","");if($0!~/^$/){imd++;sizes_md_a[imd]=$0;sizes_md_u_a[$0]=$0};if($0~/^[0-9]/){max_s=$0*1>max_s?$0:max_s;min_s=$0*1<min_s?$0:min_s}}
if(!imd){
asorti(dirar_a,sizes_md_a)
for(k in dirar_a){sizes_md_u_a[k]=k}
}

}

function table(){ #Build and print HTML table to stdout.
fileout?"":fileout="/dev/stdout"

iconames(dirar,iconarr,lnarr)

if(mdout){
readsizes_md(sizes_md,sizes_md_a,sizes_md_u_a)
split(min_s" "max_s,mdout_minmax)
head_md="# "capital(fol_nam) "\n"
md_th="| |"
md_line="|-|" # TODO перепроверить кол-во палок! TODO

for(k in sizes_md_a){ # пробегаем по размерам, указанным в sizes_md в том порядке, как там перечислено
if(sizes_md_a[k] in dirar_a){ # если указанный размер (имя подпапки) обнаружен в файловой системе
md_th=md_th "**" (sizes_md_a[k]~/^[0-9]+$/?sizes_md_a[k]"x":"") sizes_md_a[k] "**|"
md_line=md_line "-|"
}else{
delete sizes_md_a[k] # а если папки нет, то и размер нам ни к чему
}
}

asorti(all_iconar,all_iconar_s)
for(ic in all_iconar_s){
iconoext=gensub(/\.[^.]*$/,"",1,all_iconar_s[ic])
iconline_md="|**" iconoext "**|"
for(k in sizes_md_a){
#iconline_md= iconline_md  (ic && existlnar[sizes_md_a[k]"/"ic] ? "<details><summary>":"") "!["sizes_md_a[k]"]("sizes_md_a[k]"/"ic"." (tolower(sizes_md_a[k])~"scal"?"sv":"pn")"g)"  (ic && existlnar[sizes_md_a[k]"/"ic] ? "</summary> *" lnarr[ic][sizes_md_a[k]] "*</details>" : "") "|"
iconline_md= iconline_md "![""](" (all_iconar_s[ic] && existlnar[sizes_md_a[k]"/" iconoext] ?  sizes_md_a[k]"/"lnarr[iconoext][sizes_md_a[k]] ")<details><summary>*link:* </summary>*" lnarr[iconoext][sizes_md_a[k]] "*</details>" : sizes_md_a[k]"/"all_iconar_s[ic] ")") "|"
}
icontable_md=icontable_md (icontable_md?"\n":"") iconline_md
#print iconline_md
}
md_comment="Total **" length(all_iconar_s) "** icons in **" tolower(fol_nam) "** context.\n"
print head_md "\n" md_comment "\n" md_th "\n" md_line "\n" icontable_md > mdout
}else{
mdout="/dev/null"
}

if(mdbrief){
readsizes_md(sizes_brief,sizes_brief_a,sizes_brief_u_a)
brief_head_md="# "capital(fol_nam) "\nOnly the main icons are shown here (without symlinked duplicates, in sizes from "min_s"x"min_s" to "max_s"x"max_s").<br>The full icon list "(isarray(mdout_minmax)?"with sizes from "mdout_minmax[1]"x"mdout_minmax[1]" to "mdout_minmax[2]"x"mdout_minmax[2]:"")" is there: ["mdout"]("mdout")\n"
md_th="| |"
md_line="|-|"
for(k in sizes_brief_a){ # пробегаем по размерам, указанным в sizes_brief в том порядке, как там перечислено
if(sizes_brief_a[k] in dirar_a){ # если указанный размер (имя подпапки) обнаружен в файловой системе
md_th=md_th "**" (sizes_brief_a[k]~/^[0-9]+$/?sizes_brief_a[k]"x":"") sizes_brief_a[k] "**|"
md_line=md_line "-|"
}else{
delete sizes_brief_a[k] # а если папки нет, то и размер нам ни к чему
}
}

asorti(iconarr,iconarr_s)

for(ic in iconarr_s){
iconline_md="|**" iconarr_s[ic] "**|" # начинаем строку

for(k in sizes_brief_a){ # развиваем строку
iconline_md= iconline_md "![""](" sizes_brief_a[k]"/"iconarr_s[ic] "." (tolower(sizes_brief_a[k])~"scal"?"sv":"pn") "g)|"
}
brieftable_md=brieftable_md (brieftable_md?"\n":"") iconline_md
}
print brief_head_md "\n" md_th "\n" md_line "\n" brieftable_md > mdbrief

}else{
mdbrief="/dev/null"
}

print head > fileout

print "<table>\n" > fileout

print "\t<tr>" > fileout
for(i in dirar){
	print "\t\t<th>" i "</th>" > fileout
}
print "\t</tr>\n" > fileout

asorti(iconarr,iconarr_s)
for(ic in iconarr_s){

print "\t<tr>" > fileout
for(k in dirar){
#print k"/"ic
dirnam=k"/"iconarr_s[ic]
	imgtag=(existar[dirnam]?"\t\t<td><a name="dirnam"></a>\n" "\t\t\t<img src=\"./"dirnam".png\" alt=\""iconarr_s[ic]".png\">\n\t\t\t<br>"iconarr_s[ic]"\n" "\n\t\t</td>":"\t\t<td class=\"empty\"><a name="dirnam"></a>\n\t\t</td>")
	print imgtag > fileout
}
print "\t</tr>" > fileout
}

for(icl in lnarr){
print "\t<tr>" > fileout
for(k in dirar){
dirlnam=k"/"icl
	locallink=lnarr[icl][k];gsub(/\.[^.]*$/,"",locallink)
	# надо сделать из ../../apps/24/system-users ../apps/icons.html#24/system-users
	htmlpath=htmlname=fol_nam"/"fileout
	gsub(/[^/]*$/,"",htmlpath)
	gsub(/^.*\//,"",htmlname)
	if(locallink~"../../"){
		locallink=gensub("/","/"fileout"#",2,gensub("../","",2,locallink))
	}else{
		locallink="#"k"/"locallink
	}
	lnname=lnarr[icl][k];gsub(/\.[^.]*$/,"",lnname)
	linktext="iconlink "href" "icl
	linktext=icl "<br>" href
	href="<a href=\""locallink"\"><i>"lnname"</i></a>"
	imgtag=(isarray(lnarr[icl]) && existlnar[dirlnam]?"\t\t<td class=\"ln\">\n""\t\t\t<img src=\"./"k"/"icl".png\" alt=\""icl".png\">\n\t\t\t<br>"linktext"<br>\n""\n\t\t</td>":"\t\t<td class=\"empty\">\n"  "\n\t\t</td>")
	#if(lnarr[icl][k]){
		print imgtag > fileout
	#}
}
print "\t</tr>" > fileout
}

print "</table>" > fileout
print foot > fileout
}

BEGIN{
shortcut_icon="../emblems/10/emblem-symbolic-link.png"
fileout="icons.html"
mdout="icons.md"
mdbrief="README.md"
#mdout="/dev/stdout"
sizes_md="sizes_md"
sizes_brief="sizes_brief"
pwd=ENVIRON["PWD"]
prepare()
table()
}
