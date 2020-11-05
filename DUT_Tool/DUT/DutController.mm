//
//  DutController.c
//  DUT
//

//

#include "DutController.h"
#include <iostream>
#include <Foundation/Foundation.h>
#include <sstream>
#include <map>
#include <pthread.h>

using namespace std;

@protocol DataInterface <NSObject>
-(void)OnData:(void *)bytes length:(long)len;
@end

CDUTController::CDUTController()
{
    pthread_mutex_init(&_mtx, NULL);
    pthread_mutex_init(&m_lockOperate,NULL);
    
}
CDUTController::CDUTController(int index)
{
    m_index = index;
    pthread_mutex_init(&_mtx, NULL);
    pthread_mutex_init(&m_lockOperate,NULL);
}

CDUTController::~CDUTController()
{
    pthread_mutex_destroy(&_mtx);
    pthread_mutex_destroy(&m_lockOperate);
    CRequester::close();
    CSubscriber::close();
}

int CDUTController::Initial(const char *arg1, const char *arg2, void *arg)
{    
    m_RequestAddress = arg1;
    m_SubscriberAddress = arg2;
    
    CRequester::close();
    CSubscriber::close();
    CRequester::connect(m_RequestAddress.c_str());
    CSubscriber::connect(m_SubscriberAddress.c_str());
    return 0;
}

int CDUTController::Close()
{
    CRequester::close();
    CSubscriber::close();
    return 0;
}

int CDUTController::WriteString(const char * buffer)
{
     //return RequestString(buffer);
    pthread_mutex_lock(&m_lockOperate);
    int ret = RequestString(buffer);
    pthread_mutex_unlock(&m_lockOperate);
    return ret;
}

int CDUTController::SetDelegate(id object)
{
    m_object = object;
    return 0;
}

void * CDUTController::OnSubscriberData(void *pdata,long len)
{
    NSLog(@"CDUTController OnSubscriberData call");
    pthread_mutex_lock(&m_lockOperate);
    id<DataInterface> d = (id<DataInterface>)m_object;
    [d OnData:pdata  length:len];
    pthread_mutex_unlock(&m_lockOperate);
    NSLog(@"OnSubscriberData exit");
    return nullptr;
}
