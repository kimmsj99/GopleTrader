//
//  URL.swift
//  GopleComp
//
//  Created by 김민주 on 2017. 11. 10..
//  Copyright © 2017년 김민주. All rights reserved.
//

import Foundation


public let domain           = "http://gople.ghsoft.kr"      //도메인

public let newUserInfoURL   = "/company/base/getBuisnessData"   //최신 유저 정보

//MARK: - Login
public let loginURL         = "/company/base/checkLoginData"    //로그인
public let loginSuccessURL  = "/company/base/setLoginTrace"     //로그인 성공 시

//MARK: - Join
public let certifiNumURL    = "/company/base/actionSMS"         //전화번호 인증번호 전송
public let checkValiIDURL   = "/company/base/checkValiID"       //ID 중복확인
public let companyImgURL    = "/company/base/setFileUpload"     //사업자등록증 이미지 업로드
public let joinURL          = "/company/base/setSignupData"     //회원가입

//MARK: - Fint
public let findIDURL        = "/company/base/actionSMS"         //아이디 비번 찿기
public let getFindIDURL     = "/company/base/getFindUserId"     //아이디 가져오기
public let changePWURL      = "/company/base/setFindUserPw"     //비밀번호 변경

//MARK: - TabBar
public let homeURL              = "/company/base/home"              //Home

//MARK: - Regist
public let registURL            = "/company/data/view"              //등록
public let modifyURL            = "/company/data/write"             //등록에서 수정하기 페이지
public let reviewURL            = "/company/data/review"            //리뷰
public let imgRegistURL         = "/company/data/setFileUpload"     //이미지 등록

//MARK: - Schedule
public let scheduleURL          = "/company/schedule/info"          //스케줄
public let scheduleDetailURL    = "/company/schedule/detail"        //스케줄 상세보기
public let calenderURL          = "/company/schedule/view"          //스케줄 달력

//MARK: - Setting
public let serviceURL           = "/company/setting/service"        //서비스 이용 약관
public let privacyURL           = "/company/setting/privacy"        //개인정보 처리 방침
public let alertUpdateURL       = "/company/base/setAlertUpdate"    //알림 업데이트
public let logoutURL            = "/company/base/logout"            //로그아웃
public let withdrawalURL        = "/company/base/setBuisnessDelete" //회원탈퇴
