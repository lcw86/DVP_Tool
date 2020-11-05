//
//  DataQueue.hpp
//  SocketDev
//
//  Created by Ryan on 12/7/15.
//  Copyright © 2015 ___Intelligent Automation___. All rights reserved.
//

#ifndef DataQueue_hpp
#define DataQueue_hpp

#include <stdio.h>
#include <Foundation/Foundation.h>

class CDataQueue
{
public:
    CDataQueue();
    virtual ~CDataQueue();
public:
    long PushData(void * buffer,long len);
    long ClearBuffer();
    long GetBufferLen();
    long GetData(void * buffer,long len);
    
    int m_pip[2];
    
    NSMutableData * m_DataBuffer;
    
    pthread_mutex_t m_mutex;
};
#endif /* DataQueue_hpp */
