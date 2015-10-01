/**
 * Copyright (C) 2015 JianyingLi
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Alamofire
import SwiftyJSON
import Ono

class ApiClient {
    static let PAGE_SIZE: Int = 20
    
    static func isError(error: ErrorType?, failure: (code: Int, message: String) -> Void) -> Bool {
        if (error != nil) {
            failure(code: -1, message: "网络发生异常")
            return true
        }
        return false
    }

    // MAKE: 用户登录
    static func login(username: String, password: String, success: (data: User) -> Void, failure: (code: Int, message: String) -> Void) {
        let parameters: [String:AnyObject] = [
                "username": username,
                "pwd": password,
                "keep_login": 1
        ]
        Alamofire.request(.POST, URLs.LOGIN, parameters: parameters)
        .responseXMLDocument {
            (request, response, result) -> Void in
            // 请求是否发生错误
            if (isError(result.error, failure: failure)) {
                return
            }
            let rootElement: ONOXMLElement = result.value!.rootElement
            print(rootElement)
            let ret: Result_ = Result_.parse(rootElement.firstChildWithTag("result"))
            if (ret.isSuccess()) {
                let user: User = User.parse(rootElement.firstChildWithTag("user"))
                User.current(user)
                success(data: user)
            } else {
                failure(code: ret.errorCode!, message: ret.errorMessage!)
            }
        }
    }
    
    static func userNotice(success: (data: Notice) -> Void, failure: (code: Int, message: String) -> Void) {
        var uid: Int = 0
        if (User.isLogged()) {
            uid = User.current()!.uid!
        }
        let parameters: [String: AnyObject] = [
            "uid": uid
        ]
        Alamofire.request(.GET, URLs.USER_NOTICE, parameters: parameters)
            .responseXMLDocument {
                (request, response, result) -> Void in
                // 请求是否发生错误
                if (isError(result.error, failure: failure)) {
                    return
                }
                let rootElement: ONOXMLElement = result.value!.rootElement
                let ret: Result_ = Result_.parse(rootElement.firstChildWithTag("result"))
                if (ret.isSuccess()) {
                    let notice: Notice = Notice.parse(rootElement.firstChildWithTag("notice"))
                    notice.msgCount = 10
                    notice.atmeCount = 5
                    Notice.current(notice)
                    success(data: notice)
                } else {
                    failure(code: ret.errorCode!, message: ret.errorMessage!)
                }
        }
        
    }
    
    // MAKE: 资讯列表
    static func newsList(page: Int, catalog: Int, success: (data:[News]) -> Void, failure: (code:Int, message:String) -> Void) {
        // 1-所有|2-综合新闻|3-软件更新
        let parameters: [String: AnyObject] = [
                "catalog": catalog,
                "pageIndex": page,
                "pageSize": PAGE_SIZE
        ]
        Alamofire.request(.POST, URLs.NEWS_LIST, parameters: parameters)
        .responseXMLDocument {
            (request, response, result) -> Void in
            // 请求是否发生错误
            if (isError(result.error, failure: failure)) {
                return
            }
            let rootElement: ONOXMLElement = result.value!.rootElement
            let ret: Result_ = Result_.parse(rootElement.firstChildWithTag("result"))
            if (ret.isSuccess()) {
                success(data: News.parseArray(rootElement.firstChildWithTag("newslist"))!)
            } else {
                failure(code: ret.errorCode!, message: ret.errorMessage!)
            }
        }
    }
    
    static func tweetList(page: Int, uid: Int, success: (data:[Tweet]) -> Void, failure: (code:Int, message:String) -> Void) {
        // 用户ID [ 0：最新动弹，-1：热门动弹，其他：我的动弹 ]
        let parameters: [String:AnyObject] = [
                "uid": uid,
                "pageIndex": page,
                "pageSize": PAGE_SIZE
        ]
        Alamofire.request(.POST, URLs.TWEET_LIST, parameters: parameters)
        .responseXMLDocument {
            (request, response, result) -> Void in
            // 请求是否发生错误
            if (isError(result.error, failure: failure)) {
                return
            }
            let rootElement: ONOXMLElement = result.value!.rootElement
            let ret: Result_ = Result_.parse(rootElement.firstChildWithTag("result"))
            if (ret.isSuccess()) {
                success(data: Tweet.parseArray(rootElement.firstChildWithTag("tweets"), needSort: uid != -1)!)
            } else {
                failure(code: ret.errorCode!, message: ret.errorMessage!)
            }
        }
    }
    
    // MAKE: 最新动弹
    static func tweetListLatest(page: Int, success: (data:[Tweet]) -> Void, failure: (code:Int, message:String) -> Void) {
        return tweetList(page, uid: 0, success: success, failure: failure)
    }
    
    
    // MAKE: 热门动弹
    static func tweetListHot(page: Int, success: (data:[Tweet]) -> Void, failure: (code:Int, message:String) -> Void) {
        return tweetList(page, uid: -1, success: success, failure: failure)
    }
    
    // MAKE: 我的动弹
    static func tweetListMy(page: Int, success: (data:[Tweet]) -> Void, failure: (code:Int, message:String) -> Void) {
        var uid: Int = 0
        if (User.isLogged()) {
            uid = User.current()!.uid!
        }
        return tweetList(page, uid: uid, success: success, failure: failure)
    }
}