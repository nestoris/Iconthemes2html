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
			if($3~"f"&&$2~/\.png$/){gsub(/\.[^.]*$/,"",$2);iconarr[$2];dirnam=i"/"$2;existar[dirnam]=dirnam}
			if($3~"l"&&$2~/\.png$/){
				#split("",lnarr)
				#split("",lnarr[$2])
				lnfil=pwdi"/"$2
				stat(lnfil, statdata)
				gsub(/\.[^.]*$/,"",$2)
				#lnmem=i"/"$2
				lnarr[$2][i]=statdata["linkval"]
				dirlnam=i"/"$2
				existlnar[dirlnam]=dirlnam
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
if($3=="d"&&$2!~/^\.+$/&&$2~/[0-9]+/){dirar[$2]}
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
  background: white;\n\
}\n\
td.empty {\n\
  background: #CCDDDD;\n\
  border: 1px solid #666666;\n\
}\n\
td.ln {\n\
  border: 1px solid #808080;\n\
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

function table(){ #Build and print HTML table to stdout.
fileout?"":fileout="/dev/stdout"
print head > fileout

print "<table>\n" > fileout

print "\t<tr>" > fileout
for(i in dirar){
	print "\t\t<th>" i "</th>" > fileout
}
print "\t</tr>\n" > fileout

iconames(dirar,iconarr,lnarr)
for(ic in iconarr){

print "\t<tr>" > fileout
for(k in dirar){
#print k"/"ic
dirnam=k"/"ic
	imgtag=(existar[dirnam]?"\t\t<td><a name="dirnam"></a>\n" "\t\t\t<img src=\"./"dirnam".png\" alt=\""ic".png\">\n\t\t\t<br>"ic"\n" "\n\t\t</td>":"\t\t<td class=\"empty\"><a name="dirnam"></a>\n\t\t</td>")
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
fileout="icons.html"
pwd=ENVIRON["PWD"]
prepare()
table()
}
