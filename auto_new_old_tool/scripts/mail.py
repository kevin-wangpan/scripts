#!/usr/bin/env python
# -*- coding: gbk -*-
#导入smtplib和MIMEText
import smtplib,datetime,sys
from email.mime.text import MIMEText
from email.header import Header
from email.mime.multipart import MIMEMultipart
mail_content=sys.argv[1]
attachment_file=sys.argv[2]
mail_user=sys.argv[3]
mailto_str=sys.argv[4]
mailto_list=mailto_str.split(',')
mail_host="172.24.1.82"
mail_postfix="notesmail.huawei.com"
sender=mail_user+"<"+mail_user+"@"+mail_postfix+">"
######################
def send_mail(to_list,me,content,filename):
    '''
    to_list:发给谁
    sub:主题
    content:内容
    send_mail("aaa@126.com","sub","content")
    '''
    
 #   msg = MIMEText(content)
 #   
    msg = MIMEMultipart()
    #att = MIMEText(open(filename, 'rb').read(), 'base64', 'gb2312')
    #att["Content-Type"] = 'application/octet-stream'
    #att["Content-Disposition"] = 'attachment; filename="log.tar.tgz"'
    #msg.attach(att)
    msg['From'] = me
    msg['To'] = ",".join(to_list)
    msg['Subject'] = Header('New DTS (' + str(datetime.date.today()) + ') :' + content,'utf-8')
    try:
        s = smtplib.SMTP()
        s.connect(mail_host)
        s.sendmail(me, to_list, msg.as_string())
        s.close()
        return True
    except Exception, e:
        print str(e)
        return False
if __name__ == '__main__':
    if send_mail(mailto_list,sender,mail_content,attachment_file):
        print "send mail success"
    else:
        print "send mail failed"
