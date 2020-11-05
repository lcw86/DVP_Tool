//
//  DataQueue.cpp
//  SocketDev
//
//  Created by Ryan on 12/7/15.
//  Copyright © 2015  Automation___. All rights reserved.
//

#include "DataQueue.hpp"
#include <sys/ioctl.h>
#include <iostream>


CDataQueue::CDataQueue()
{
    if (pipe(m_pip))
    {
        std::cout<<"[CDataQueue]:"<<"Create pipe failed"<<std::endl;
    }
    
    m_DataBuffer = [[NSMutableData alloc]init];
    pthread_mutex_init(&m_mutex, nullptr);
}
CDataQueue::~CDataQueue()
{
    pthread_mutex_destroy(&m_mutex);
}

long CDataQueue::PushData(void *buffer, long len)
{
    pthread_mutex_lock(&m_mutex);
#if 0
    long ret = write(m_pip[1], buffer, len);
    std::cout<<"[CDataQueue]:"<<"push data into buffer,with lenght:"<<ret<<std::endl;
#else
    long ret = len;
    [m_DataBuffer appendBytes:buffer length:len];
//    std::cout<<"[CDataQueue]:"<<"push data into buffer,with lenght:"<<ret<<std::endl;
#endif
    pthread_mutex_unlock(&m_mutex);
    return ret;
}

long CDataQueue::GetBufferLen()
{
    pthread_mutex_lock(&m_mutex);
#if 0
    int bytes;
    int n = ioctl(m_pip[0], FIONREAD,&bytes);
    return (n==0)?bytes:-1;
#else
    pthread_mutex_unlock(&m_mutex);
    return [m_DataBuffer length];
#endif
}

long CDataQueue::GetData(void *buffer, long len)
{
    pthread_mutex_lock(&m_mutex);
#if 0
    return read(m_pip[0], buffer, len);
#else
    unsigned char * p = (unsigned char * )[m_DataBuffer bytes];
    memcpy(buffer, p, [m_DataBuffer length]);
    [m_DataBuffer setLength:0];
    pthread_mutex_unlock(&m_mutex);
    return [m_DataBuffer length];
#endif
}

long CDataQueue::ClearBuffer()
{
    pthread_mutex_lock(&m_mutex);
#if 0
    long len = this->GetBufferLen();
    if (len<=0) {
        return len;
    }
    unsigned char *pbuf = new unsigned char[len];
    long ret = this->GetData(pbuf, len);
    delete pbuf;    //discard
    return ret;
#else
    [m_DataBuffer setLength:0];
    pthread_mutex_unlock(&m_mutex);
    return 0;
#endif
}
