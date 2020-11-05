//
//  ZMQinterface.cpp
//  Server
//
//  Created by Ryan on 8/15/15.
//  Copyright (c) 2015 ___Intelligent Automation___. All rights reserved.
//

#include "ZMQinterface.h"
#include "zmq.h"


#include <iostream>
#include <sstream>

#include <unistd.h>

#include <regex>

#define CLI_CR_RED          "\033[31m"
#define CLI_CR_YELLOW       "\033[33m"
#define CLI_CR_CLOSE        "\033[0m"


#define PORT_BASE       6000


using namespace std;

std::map<std::string, int>  CZMQHost::m_portlist;


//Host
CZMQHost::CZMQHost()
{
    m_bMonitorRequest = true;
}


CZMQHost::CZMQHost(const char *name,int port)
{
}

CZMQHost::~CZMQHost()
{
    m_bMonitorRequest  = false;
//    pthread_join(m_thread, nullptr);
    std::cout<<zmq_close(m_SocketPubliser)<<std::endl;
    std::cout<<zmq_ctx_term(m_ContextPublisher)<<std::endl;
//    zmq_close(m_SocketPubliser);
//    zmq_ctx_term(m_ContextPublisher);
    zmq_close(m_SocketReply);
    zmq_ctx_term(m_ContextReply);
}

int CZMQHost::CreateHost(int pubPort, int repPort)
{
    m_bMonitorRequest = true;
    if (pubPort==-1 || repPort==-1) {
        return -1;
    }
    else
    {
        map<string, int>::iterator pos;
        for (pos = m_portlist.begin();pos!=m_portlist.end();++pos)
        {
            if (pos->second==pubPort||pos->second==repPort) {
                //                port = PORT_BASE+(int)m_portlist.size()*2;
                break;
            }
        }
    }
    //Create Socket
    m_ContextPublisher = zmq_ctx_new();
    
    if (!m_ContextPublisher) {
        std::cerr<<CLI_CR_RED<<"[ NULL ] "<< "DeviceHost::failed to create context!"<<std::endl<<CLI_CR_CLOSE;
    }
    
    m_ContextReply = zmq_ctx_new();
    
    if (!m_ContextReply) {
        std::cerr<<CLI_CR_RED<<"[ NULL ] " << "DeviceHost::failed to create context!"<<std::endl<<CLI_CR_CLOSE;
    }
    
    m_SocketPubliser = zmq_socket(m_ContextPublisher, ZMQ_PUB);
    
    if (!m_SocketPubliser) {
        std::cerr<<CLI_CR_RED<<"[ NULL ] " << "DeviceHost::failed to create publiser socket!"<<std::endl<<CLI_CR_CLOSE;
    }
    
    m_SocketReply = zmq_socket(m_ContextReply, ZMQ_REP);
    
    if (!m_SocketReply) {
        std::cerr<<CLI_CR_RED<<"[ NULL ] " << "DeviceHost::failed to create reply socket!"<<std::endl<<CLI_CR_CLOSE;
    }
    
    usleep(1000*500);   //sleep some time
    
    
    ostringstream oss;
    oss<<"tcp://*:"<<pubPort;
    
    int ret = zmq_bind(m_SocketPubliser, oss.str().c_str());
    if (ret <0) {
        std::cerr<<CLI_CR_RED<<"[ NULL ] "<< "DeviceHost::Publiser socket,failed to bind port number :"<<oss.str()<<" with return value :"<<ret<<std::endl<<CLI_CR_CLOSE;
    }
    else
    {
        std::cout<<"[ NULL ] "<< "DeviceHost::Create PUBLISER server,bind with address :"<<oss.str()<<std::endl;
    }
    
    ostringstream oss2;
    oss2<<"tcp://*:"<<repPort;
    ret = zmq_bind(m_SocketReply, oss2.str().c_str());
    if (ret <0) {
        std::cerr<<CLI_CR_RED<<"[ NULL ] " << "DeviceHost::Reply socket failed to bind port number :"<<oss2.str()<<" with return value :"<<ret<<std::endl<<CLI_CR_CLOSE;
    }
    else
    {
        std::cout<<"[ NULL ] "<< "DeviceHost::Create REPLY server,bind with address :"<<oss2.str()<<std::endl;
    }
    
    
    
    pthread_create(&m_thread, nullptr, CZMQHost::ThreadEntry, this);
    
    return ret;
}

int CZMQHost::CreateHost(const char *name,int port)
{
    m_bMonitorRequest = true;
    if (port==-1) {
        port = PORT_BASE+(int)m_portlist.size()*2;
    }
    else
    {
        map<string, int>::iterator pos;
        for (pos = m_portlist.begin();pos!=m_portlist.end();++pos)
        {
            if (pos->second==port||pos->second==port+1) {
//                port = PORT_BASE+(int)m_portlist.size()*2;
                break;
            }
        }
    }
    
    m_portlist[name]=port;
    //Create Socket
    m_ContextPublisher = zmq_ctx_new();
    
    if (!m_ContextPublisher) {
        std::cerr<<CLI_CR_RED<<"[" <<name<<"] "<< "DeviceHost::failed to create context!"<<std::endl<<CLI_CR_CLOSE;
    }
    
    m_ContextReply = zmq_ctx_new();
    
    if (!m_ContextReply) {
        std::cerr<<CLI_CR_RED<<"[" <<name<<"] " << "DeviceHost::failed to create context!"<<std::endl<<CLI_CR_CLOSE;
    }
    
    m_SocketPubliser = zmq_socket(m_ContextPublisher, ZMQ_PUB);
    
    if (!m_SocketPubliser) {
        std::cerr<<CLI_CR_RED<<"[" <<name<<"] " << "DeviceHost::failed to create publiser socket!"<<std::endl<<CLI_CR_CLOSE;
    }
    
    m_SocketReply = zmq_socket(m_ContextReply, ZMQ_REP);
    
    if (!m_SocketReply) {
        std::cerr<<CLI_CR_RED<<"[" <<name<<"] " << "DeviceHost::failed to create reply socket!"<<std::endl<<CLI_CR_CLOSE;
    }
    
    usleep(1000*500);   //sleep some time
    
    
    ostringstream oss;
    oss<<"tcp://*:"<<port;
    
    int ret = zmq_bind(m_SocketPubliser, oss.str().c_str());
    if (ret <0) {
        std::cerr<<CLI_CR_RED<<"[" <<name<<"] "<< "DeviceHost::Publiser socket,failed to bind port number :"<<oss.str()<<" with return value :"<<ret<<std::endl<<CLI_CR_CLOSE;
    }
    else
    {
        std::cout<<"[" <<name<<"] "<< "DeviceHost::Create PUBLISER server,bind with address :"<<oss.str()<<std::endl;
    }
    
    ostringstream oss2;
    oss2<<"tcp://*:"<<port+1;
    ret = zmq_bind(m_SocketReply, oss2.str().c_str());
    if (ret <0) {
        std::cerr<<CLI_CR_RED<<"[" <<name<<"] " << "DeviceHost::Reply socket failed to bind port number :"<<oss2.str()<<" with return value :"<<ret<<std::endl<<CLI_CR_CLOSE;
    }
    else
    {
        std::cout<<"[" <<name<<"] "<< "DeviceHost::Create REPLY server,bind with address :"<<oss2.str()<<std::endl;
    }
    
    
    
    pthread_create(&m_thread, nullptr, CZMQHost::ThreadEntry, this);

    return ret;
}

static void free_buffer (void *data, void *hint)
{
    delete[] (unsigned char *)data;
}

int CZMQHost::SendMessage(void *buffer, int length)
{
    unsigned char * pbuffer = new unsigned char[length];
    memcpy(pbuffer, buffer, length);
    zmq_msg_t msg;
    zmq_msg_init_data(&msg, pbuffer, length, free_buffer, &length);
    int ret = zmq_msg_send(&msg, m_SocketPubliser, 0);
    if (ret<0) {
        std::cerr<<CLI_CR_RED<<"ZMQ msg send failed! cmd : "<<buffer<<" length :"<<length<<std::endl<<CLI_CR_CLOSE;
    }
    zmq_msg_close(&msg);
    return 0;
}

int CZMQHost::SendString(const char *buffer)
{
    return SendMessage((void *)buffer, (int)strlen(buffer)+1);
}

#define ACK         "ACK"
void * CZMQHost::HostLoop(void *arg)
{
    while (m_bMonitorRequest) {
        zmq_msg_t msg;
        zmq_msg_init(&msg);
        zmq_msg_recv(&msg, m_SocketReply, 0);
        void * pbuffer = zmq_msg_data(&msg);
        size_t len = zmq_msg_size(&msg);
//        usleep(1000*1000*5);
        OnMessage(pbuffer, len);
        zmq_msg_close(&msg);
        zmq_msg_init_data(&msg, (void *)"ACK", 4, nullptr, nullptr);
        zmq_msg_send(&msg, m_SocketReply, 0);
        
        zmq_msg_close(&msg);
    }
    return nullptr;
}

void *  CZMQHost::OnMessage(void *buffer, long length)
{
    std::cout<<"int CZMQHost::OnMessage(void *buffer, int length)"<<endl;
    return 0;
}

void * CZMQHost::ThreadEntry(void *arg)
{
    CZMQHost * pThis = (CZMQHost *)arg;
    return pThis->HostLoop(arg);
}


///Client
CZMQClient::CZMQClient()
{
}

CZMQClient::CZMQClient(const char * name)
{
    if (!name) {
        return;
    }
    m_bMonitorPublisher = false;
    
    map<string, int>::iterator pos;
    pos = CZMQHost::m_portlist.find(name);
    if (pos == CZMQHost::m_portlist.end()) {
        std::cout<<"Couldn't find specail server!"<<std::endl;
    }
    
    m_port = pos->second;
    
}

CZMQClient::~CZMQClient()
{
    m_bMonitorPublisher = false;
    pthread_join(m_thread, nullptr);
    zmq_ctx_term(m_ContextSubscriber);
    zmq_ctx_term(m_ContextRequest);
    zmq_close(m_SocketRequest);
    zmq_close(m_SocketSubscriber);
}

int CZMQClient::Connect(const char * ip,int subPort, int reqPort)
{
    if (subPort==-1 || reqPort == -1) {
        return -1;
    }
    
    //Create Socket
    m_ContextSubscriber = zmq_ctx_new();
    
    if (!m_ContextSubscriber) {
        std::cerr<<CLI_CR_RED << "DeviceClient::failed to create subscriber context!"<<std::endl<<CLI_CR_CLOSE;
    }
    
    m_ContextRequest = zmq_ctx_new();
    
    if (!m_ContextRequest) {
        std::cerr<<CLI_CR_RED << "DeviceClient::failed to create request context!"<<std::endl<<CLI_CR_CLOSE;
    }
    
    m_SocketSubscriber = zmq_socket(m_ContextSubscriber, ZMQ_SUB);
    
    if (!m_SocketSubscriber) {
        std::cerr<<CLI_CR_RED << "DeviceClient::failed to create subscriber socket!"<<std::endl<<CLI_CR_CLOSE;
    }
    
    if(zmq_setsockopt (m_SocketSubscriber, ZMQ_SUBSCRIBE, "", 0) < 0){
        std::cerr<<CLI_CR_RED << "zmqw::zmqw failed to set ZMQ_SUB socket ZMQ_SUBSCRIBE option.\n"<<CLI_CR_CLOSE;
    }
    
    
    m_SocketRequest = zmq_socket(m_ContextRequest, ZMQ_REQ);
    
    if (!m_SocketRequest) {
        std::cerr<<CLI_CR_RED << "DeviceHost::failed to create reply socket!"<<std::endl<<CLI_CR_CLOSE;
    }
    
    int recTime = 3000;
    if(zmq_setsockopt (m_SocketRequest, ZMQ_RCVTIMEO, &recTime, sizeof(recTime)) < 0){
        std::cerr<<CLI_CR_RED << "zmqw::zmqw failed to set RQUEST socket ZMQ_RCVTIMEO option.\n"<<CLI_CR_CLOSE;
    }
    
    //connect
    std::string str(ip);
    ostringstream oss;
    oss<<ip<<":"<<subPort;
    int ret = zmq_connect(m_SocketSubscriber, oss.str().c_str());
    if (ret<0) {
        std::cout<<"Fail to connect to PUBLISHER server:"<<oss.str()<<std::endl;
//        return ret;
    }
    else
    {
        std::cout<<"Connect to PUBLISHER server:"<<oss.str()<<std::endl;
    }
    
    ostringstream  oss2;
    oss2<<ip<<":"<<(reqPort);
    ret = zmq_connect(m_SocketRequest, oss2.str().c_str());
    if (ret<0) {
        std::cout<<"Fail to connect to REQUEST server:"<<oss2.str()<<std::endl;
        return ret;
    }
    else
    {
        std::cout<<"Connect to REPLY server:"<<oss2.str()<<std::endl;
    }
    
    m_bMonitorPublisher = true;
    pthread_create(&m_thread, nullptr, CZMQClient::ThreadEntry, this);
    return 0;
}


int CZMQClient::Connect(const char * ip,int port)
{
    if (port==-1) {
        port = m_port;
    }
    
    //Create Socket
    m_ContextSubscriber = zmq_ctx_new();
    
    if (!m_ContextSubscriber) {
        std::cerr<<CLI_CR_RED << "DeviceClient::failed to create subscriber context!"<<std::endl<<CLI_CR_CLOSE;
    }
    
    m_ContextRequest = zmq_ctx_new();
    
    if (!m_ContextRequest) {
        std::cerr<<CLI_CR_RED << "DeviceClient::failed to create request context!"<<std::endl<<CLI_CR_CLOSE;
    }
    
    m_SocketSubscriber = zmq_socket(m_ContextSubscriber, ZMQ_SUB);
    
    if (!m_SocketSubscriber) {
        std::cerr<<CLI_CR_RED << "DeviceClient::failed to create subscriber socket!"<<std::endl<<CLI_CR_CLOSE;
    }
    
    if(zmq_setsockopt (m_SocketSubscriber, ZMQ_SUBSCRIBE, "", 0) < 0){
        std::cerr<<CLI_CR_RED << "zmqw::zmqw failed to set ZMQ_SUB socket ZMQ_SUBSCRIBE option.\n"<<CLI_CR_CLOSE;
    }
    
    
    m_SocketRequest = zmq_socket(m_ContextRequest, ZMQ_REQ);
    
    if (!m_SocketRequest) {
        std::cerr<<CLI_CR_RED << "DeviceHost::failed to create reply socket!"<<std::endl<<CLI_CR_CLOSE;
    }
    
    int recTime = 3000;
    if(zmq_setsockopt (m_SocketRequest, ZMQ_RCVTIMEO, &recTime, sizeof(recTime)) < 0){
        std::cerr<<CLI_CR_RED << "zmqw::zmqw failed to set RQUEST socket ZMQ_RCVTIMEO option.\n"<<CLI_CR_CLOSE;
    }

    //connect
    std::string str(ip);
    ostringstream oss;
    oss<<ip<<":"<<port;
    int ret = zmq_connect(m_SocketSubscriber, oss.str().c_str());
    if (ret<0) {
        std::cout<<"Fail to connect to PUBLISHER server:"<<oss.str()<<std::endl;
        return ret;
    }
    else
    {
        std::cout<<"Connect to PUBLISHER server:"<<oss.str()<<std::endl;
    }
    
    ostringstream  oss2;
    oss2<<ip<<":"<<(port+1);
    ret = zmq_connect(m_SocketRequest, oss2.str().c_str());
    if (ret<0) {
        std::cout<<"Fail to connect to REQUEST server:"<<oss2.str()<<std::endl;
        return ret;
    }
    else
    {
        std::cout<<"Connect to REPLY server:"<<oss2.str()<<std::endl;
    }
    
    m_bMonitorPublisher = true;
    pthread_create(&m_thread, nullptr, CZMQClient::ThreadEntry, this);
    return 0;
}


int CZMQClient::SendMessage(void *buffer, int leng)
{
    unsigned char * pbuffer = new unsigned char[leng];
    memcpy(pbuffer, buffer, leng);
    
    zmq_msg_t msg;
    zmq_msg_init_data(&msg, pbuffer, leng, free_buffer, &leng);
    int ret = zmq_msg_send(&msg, m_SocketRequest, 0);
    if (ret<0) {
        std::cerr<<CLI_CR_RED<<"ZMQ msg send failed! cmd : "<<(char *)buffer<<" length :"<<leng<<std::endl<<CLI_CR_CLOSE;
    }
    
    zmq_msg_recv(&msg, m_SocketRequest, 0);
    zmq_msg_close(&msg);
    return ret;
}

int CZMQClient::SendString(const char *buffer)
{
    return this->SendMessage((void*)buffer, (int)strlen(buffer)+1);
}

void* CZMQClient::ThreadEntry(void *arg)
{
    CZMQClient * pThis = (CZMQClient *)arg;
    return pThis->ClientLoop(arg);
}

void * CZMQClient::ClientLoop(void *arg)
{
    while (m_bMonitorPublisher) {
        zmq_msg_t msg;
        zmq_msg_init(&msg);
        zmq_msg_recv(&msg, m_SocketSubscriber, 0);
        void * pbuffer = zmq_msg_data(&msg);
        size_t len = zmq_msg_size(&msg);
        OnMessage(pbuffer, len);
        zmq_msg_close(&msg);
    }
    return nullptr;
    

}

void *  CZMQClient::OnMessage(void *buffer, long length)
{
    std::cout<<"int CZMQClient::OnMessage(void *buffer, int length)"<<endl;
    return 0;
}

