package com.learnos.auth.model;

public enum Role {
    LEARNER, // the actual student - self-registers via mobile/company code
    USER,    // staff account created by an Admin: can manage content + create learners
    TUTOR,   // staff account: can manage courses/modules/lessons only
    ADMIN    // full control
}