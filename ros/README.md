## ros
ddns
```
#更新ALIDDNS脚本精简版#    
#定义更新的域名#    
:global ddns1 "ros.xxx.top"    
#定义阿里云ID#    
:global id1 "xxxxx"    
#定义阿里云Secret#    
:global secret1 "xxxxxxxx"    
#下面内容请勿修改#    
#更新IPV4#    
:local results [/tool fetch url=("https://mail.ros6.com:6180/id=$id1&secret=$secret1&domain=$ddns1") check-certificate=no as-value output=user]  
:if ($results->"status" = "finished") do={  
:local result ($results->"data")  
:log warning $result  
}  
```
