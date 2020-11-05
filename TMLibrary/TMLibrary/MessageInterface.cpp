//
//  MessageInterface.cpp
//  Server
//
//  Created by Ryan on 8/20/15.
//  Copyright (c) 2015 ___Intelligent Automation___. All rights reserved.
//

#include "MessageInterface.h"
#include <map>
#include <iostream>



CMessageHost::CMessageHost()
{
    m_pCallBack = nullptr;
    pContext = nullptr;
}

CMessageHost::~CMessageHost()
{
}

void * CMessageHost::OnMessage(void *buffer, long length)
{
    //std::cout<<length<<std::endl;
    const char * cmd = (const char *)buffer;
    long len=strlen(cmd)+1;
    const char * pbuffer = cmd+len;
    const char * pkey=nullptr;
    const char * pvalue=nullptr;
    std::map<std::string, std::string> map;
    int index=0;
    while (len<length) {
        if (pbuffer) {
            if (index%2) {
                pvalue = pbuffer;
                map[pkey]=pvalue;
            }
            else
            {
                pkey = pbuffer;
            }
            //std::cout<<"Get Message : "<<pbuffer<<" len: "<<len<<std::endl;
            len+=strlen(pbuffer)+1;
            pbuffer=pbuffer+strlen(pbuffer)+1;
            index++;
        }
    }
    
    /*
    std::cout<<"command : "<<cmd<<std::endl;
    std::map<std::string, std::string>::iterator pos;
    for (pos = map.begin();pos!=map.end();++pos)
    {
        std::cout<<pos->first<<"="<<pos->second<<std::endl;
    }
     */
    
    if (!cmd) {
        cmd="";
    }
    if (m_pCallBack) {
        m_pCallBack(std::string(cmd),map,pContext);
    }
    
    return nullptr;
}

int CMessageHost::SetCallBack(MessageCallBack pCallBack,void * context)
{
    pContext = context;
    m_pCallBack = pCallBack;
    return 0;
}


int CMessageHost::SendMessage(std::string cmd, std::map<std::string, std::string> *arg)
{
    long length=cmd.length()+1;
    std::map<std::string, std::string>::iterator pos;
    
    if (arg) {
        for (pos = arg->begin();pos!=arg->end();++pos)
        {
            length+=pos->first.length()+1;
            length+=pos->second.length()+1;
        }
    }
    
    
    char * buffer = new char[length];
    memset(buffer, 0, length);
    long index = cmd.length()+1;
    memcpy(buffer, cmd.c_str(), index);
    
    if (arg) {
        for (pos = arg->begin();pos!=arg->end();++pos)
        {
            long len = pos->first.length()+1;
            memcpy(buffer+index, pos->first.c_str(), len);
            //std::cout<<"index : "<<index<<" data : "<<buffer+index<<std::endl;
            index+=len;
            
            len = pos->second.length()+1;
            memcpy(buffer+index, pos->second.c_str(), len);
            //std::cout<<"index : "<<index<<" data : "<<buffer+index<<std::endl;
            index+=len;
        }
        
    }
    
    CZMQHost::SendMessage(buffer, (int)length);
    //std::cout<<length<<std::endl;
    delete[] buffer;
    
    return 0;
}



//Message Client
CMessageClient::CMessageClient()
{
    m_pCallBack = nullptr;
    pContext = nullptr;
}

CMessageClient::~CMessageClient()
{
}

int CMessageClient::SendMessage(std::string cmd, std::map<std::string, std::string> *arg)
{
    long length=cmd.length()+1;
    std::map<std::string, std::string>::iterator pos;
    
    if (arg) {
        for (pos = arg->begin();pos!=arg->end();++pos)
        {
            length+=pos->first.length()+1;
            length+=pos->second.length()+1;
        }
    }
    
    
    char * buffer = new char[length];
    memset(buffer, 0, length);
    long index = cmd.length()+1;
    memcpy(buffer, cmd.c_str(), index);
    
    if (arg) {
        for (pos = arg->begin();pos!=arg->end();++pos)
        {
            long len = pos->first.length()+1;
            memcpy(buffer+index, pos->first.c_str(), len);
            //std::cout<<"index : "<<index<<" data : "<<buffer+index<<std::endl;
            index+=len;
            
            len = pos->second.length()+1;
            memcpy(buffer+index, pos->second.c_str(), len);
            //std::cout<<"index : "<<index<<" data : "<<buffer+index<<std::endl;
            index+=len;
        }

    }
    
    CZMQClient::SendMessage(buffer, (int)length);
    //std::cout<<length<<std::endl;
    delete[] buffer;
    
    return 0;
}

int CMessageClient::SetCallBack(MessageCallBack pCallBack,void * context)
{
    pContext = context;
    m_pCallBack = pCallBack;
    return 0;
}

void * CMessageClient::OnMessage(void *buffer, long length)
{
    //std::cout<<length<<std::endl;
    const char * cmd = (const char *)buffer;
    long len=strlen(cmd)+1;
    const char * pbuffer = cmd+len;
    const char * pkey=nullptr;
    const char * pvalue=nullptr;
    std::map<std::string, std::string> map;
    int index=0;
    while (len<length) {
        if (pbuffer) {
            if (index%2) {
                pvalue = pbuffer;
                map[pkey]=pvalue;
            }
            else
            {
                pkey = pbuffer;
            }
            //std::cout<<"Get Message : "<<pbuffer<<" len: "<<len<<std::endl;
            len+=strlen(pbuffer)+1;
            pbuffer=pbuffer+strlen(pbuffer)+1;
            index++;
        }
    }
    

    
    if (!cmd) {
        cmd="";
    }
    if (m_pCallBack) {
        m_pCallBack(std::string(cmd),map,pContext);
    }
    
    return nullptr;
}

