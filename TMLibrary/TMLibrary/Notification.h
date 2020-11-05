//
//  Notification.h
//  TMLibrary
//
//  Created by Ryan on 5/31/15.
//  Copyright (c) 2015 ___Intelligent Automation___. All rights reserved.
//

#ifndef __TMLibrary__Notification__
#define __TMLibrary__Notification__

#include <stdio.h>

class Notification {
public:
    Notification(const char * name,void * context);
    virtual~Notification();
    
protected:
    char m_name[32];
    void * m_context;
};

#endif /* defined(__TMLibrary__Notification__) */
