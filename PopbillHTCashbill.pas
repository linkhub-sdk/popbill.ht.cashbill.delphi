(*
*=================================================================================
* Unit for base module for Popbill API SDK. It include base functionality for
* RESTful web service request and parse json result. It uses Linkhub module
* to accomplish authentication APIs.
*
* http://www.popbill.com
* Author : Jeong Yohan (code@linkhub.co.kr)
* Written : 2016-06-10
* Thanks for your interest. 
*=================================================================================
*)
unit PopbillHTCashbill;

interface

uses
        TypInfo,SysUtils,Classes,
        Popbill,
        Linkhub;
type

        EnumQueryType = (SELL,BUY);


        THometaxCBChargeInfo = class
        public
                unitCost        : string;
                chargeMethod    : string;
                rateSystem      : string;
        end;

        THometaxCBFlatRate = class
        public
                referenceID     : string;
                contractDt      : string;
                baseDate        : Integer;
                useEndDate      : string;
                state           : Integer;
                closeRequestYN  : boolean;
                useRestrictYN   : boolean;
                closeOnExpired  : boolean;
                unPaidYN        : boolean;
        end;

        THometaxCBJobInfo = class
        public
                jobID           : String;
                jobState        : Integer;
                queryType       : String;
                queryDateType   : String;
                queryStDate     : String;
                queryEnDate     : String;
                errorCode       : Integer;
                errorReason     : String;
                jobStartDT      : String;
                jobEndDT        : String;
                collectCount    : Integer;
                regDT           : String;

        end;

        THomeTaxCBJobInfoList = Array Of THometaxCBJobInfo;

        TCashbillSummary = class
        public
                count : Integer;
                supplyCostTotal : Integer;
                taxTotal : Integer;
                serviceFeeTotal : Integer;
                amountTotal : Integer;
        end; 

        THometaxCashbill = class
        public
                ntsconfirmNum   : string;
                tradeDT         : string;
                tradeUsage      : string;
                tradeType       : string;
                supplyCost      : string;
                tax             : string;
                serviceFee      : string;
                totalAmount     : string;
                franchiseCorpNum        : string;
                franchiseCorpName       : string;
                franchiseCorpType       : Integer;
                identityNum             : string;
                identityNumType         : Integer;
                customerName            : string;
                cardOwnerName           : string;
                deductionType           : Integer;

        end;

        THometaxCBList = Array Of THometaxCashbill;

        THomeTaxCBSearchList = class
        public
                code            : Integer;
                total           : Integer;
                perPage         : Integer;
                pageNum         : Integer;
                pageCount       : Integer;
                message         : String;
                list            : THometaxCBList;
                destructor Destroy; override;
        end;


        THometaxCBService = class(TPopbillBaseService)
        private
                function jsonToHTCashbillJobInfo(json : String) : THometaxCBJobInfo;

        public
                constructor Create(LinkID : String; SecretKey : String);

                // 과금 정보 확인
                function GetChargeInfo (CorpNum : string) : THometaxCBChargeInfo; overload;
                // 과금 정보 확인
                function GetChargeInfo (CorpNum : string; UserID : string) : THometaxCBChargeInfo; overload;                
                
                // 수집 요청
                function RequestJob (CorpNum : string; queryType:EnumQueryType; SDate: String; EDate :String) : string; overload;
                // 수집 요청
                function RequestJob (CorpNum : string; queryType:EnumQueryType; SDate: String; EDate :String; UserID :String) : string; overload;                

                // 수집 상태 확인
                function GetJobState ( CorpNum : string; jobID : string) : THometaxCBJobInfo; overload;
                // 수집 상태 확인
                function GetJobState ( CorpNum : string; jobID : string; UserID :String) : THometaxCBJobInfo; overload;                

                // 수집 상태 목록 확인
                function ListActiveState (CorpNum : string) : THomeTaxCBJobInfoList; overload;
                // 수집 상태 목록 확인
                function ListActiveState (CorpNum : string; UserID:String) : THomeTaxCBJobInfoList; overload;

                // 수집결과 조회
                function Search (CorpNum:string; JobID: String; TradeType : Array Of String; TradeUsage : Array Of String; Page: Integer; PerPage : Integer; Order: String) : THomeTaxCBSearchList; overload;
                // 수집결과 조회
                function Search (CorpNum:string; JobID: String; TradeType : Array Of String; TradeUsage : Array Of String; Page: Integer; PerPage : Integer; Order: String; UserID: String) : THomeTaxCBSearchList; overload;

                
                // 수집결과 요약정보 조회
                function Summary (CorpNum:string; JobID: String; TradeType : Array Of String; TradeUsage : Array Of String) : TCashbillSummary; overload;
                // 수집결과 요약정보 조회
                function Summary (CorpNum:string; JobID: String; TradeType : Array Of String; TradeUsage : Array Of String; UserID:string) : TCashbillSummary; overload;                

                // 정액제 신청 URL
                function GetFlatRatePopUpURL(CorpNum: string; UserID : String) : string;

                // 정액제 상태 확인
                function GetFlatRateState (CorpNum : string ) : THometaxCBFlatRate; overload;
                // 정액제 상태 확인
                function GetFlatRateState (CorpNum : string; UserID: string ) : THometaxCBFlatRate; overload;                

                // 홈택스 공인인증서 등록 URL
                function GetCertificatePopUpURL(CorpNum: string; UserID : String) : string;

                // 홈택스 공인인증서 만료일자 확인
                function GetCertificateExpireDate (CorpNum : string) : string; overload;
                // 홈택스 공인인증서 만료일자 확인
                function GetCertificateExpireDate (CorpNum : string; UserID: string) : string; overload;

        end;

implementation
destructor THomeTaxCBSearchList.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(list)-1 do
    if Assigned(list[i]) then
      list[i].Free;
    SetLength(list, 0);
    inherited Destroy;
end;

constructor THometaxCBService.Create(LinkID : String; SecretKey : String);
begin
       inherited Create(LinkID,SecretKey);
       AddScope('141');
end;

function THometaxCBService.jsonToHTCashbillJobInfo(json : String) : THometaxCBJobInfo;
begin
        result := THometaxCBJobInfo.Create;

        result.jobID := getJsonString(json, 'jobID');
        result.jobState := getJsonInteger(json, 'jobState');
        result.queryType := getJsonString(json, 'queryType');
        result.queryDateType := getJsonString(json, 'queryDateType');
        result.queryStDate := getJsonString(json, 'queryStDate');
        result.queryEnDate := getJsonString(json, 'queryEnDate');
        result.errorCode := getJsonInteger(json, 'errorCode');
        result.errorReason := getJsonString(json, 'errorReason');
        result.jobStartDT := getJsonString(json, 'jobStartDT');
        result.jobEndDT := getJsonString(json, 'jobEndDT');
        result.collectCount := getJsonInteger(json, 'collectCount');
        result.regDT := getJsonString(json, 'regDT');
end;



function THometaxCBService.GetFlatRatePopUpURL(CorpNum: string; UserID : String) : string;
var
        responseJson : String;
begin

        responseJson := httpget('/HomeTax/Cashbill?TG=CHRG',CorpNum,UserID);

        result := getJSonString(responseJson,'url');
end;


function THometaxCBService.GetCertificatePopUpURL(CorpNum: string; UserID : String) : string;
var
        responseJson : String;
begin

        responseJson := httpget('/HomeTax/Cashbill?TG=CERT',CorpNum,UserID);

        result := getJSonString(responseJson,'url');
end;


function THometaxCBService.GetCertificateExpireDate(CorpNum: string) : string;
begin
        result := GetCertificateExpireDate(CorpNum, '');
end;

function THometaxCBService.GetCertificateExpireDate(CorpNum: string; UserID:string) : string;
var
        responseJson : String;
begin

        responseJson := httpget('/HomeTax/Cashbill/CertInfo',CorpNum,UserID);

        result := getJSonString(responseJson,'certificateExpiration');
end;


function THometaxCBService.GetChargeInfo (CorpNum : string) : THometaxCBChargeInfo;
begin
        result := GetChargeInfo(CorpNum, '');
end;

function THometaxCBService.GetChargeInfo (CorpNum : string; UserID: String) : THometaxCBChargeInfo;
var
        responseJson : String;
begin
        responseJson := httpget('/HomeTax/Cashbill/ChargeInfo',CorpNum,UserID);

        try
                result := THometaxCBChargeInfo.Create;

                result.unitCost := getJSonString(responseJson, 'unitCost');
                result.chargeMethod := getJSonString(responseJson, 'chargeMethod');
                result.rateSystem := getJSonString(responseJson, 'rateSystem');

        except on E:Exception do
                raise EPopbillException.Create(-99999999,'결과처리 실패.[Malformed Json]');
        end;
end;

function THometaxCBService.GetFlatRateState (CorpNum : string ) : THometaxCBFlatRate;
begin
        result := GetFlatRateState(CorpNum, '');
end;


function THometaxCBService.GetFlatRateState (CorpNum : string; UserID:string ) : THometaxCBFlatRate;
var
        responseJson : String;
begin
        responseJson := httpget('/HomeTax/Cashbill/Contract',CorpNum, UserID);
       
        try
                result := THometaxCBFlatRate.Create;
                result.referenceID := getJSonString(responseJson, 'referenceID');
                result.contractDT := getJSonString(responseJson, 'contractDT');
                result.baseDate := getJsonInteger(responseJson, 'baseDate');
                result.useEndDate := getJSonString(responseJson, 'useEndDate');
                result.state := getJsonInteger(responseJson, 'state');
                result.closeRequestYN := getJsonBoolean(responseJson, 'closeRequestYN');
                result.useRestrictYN := getJsonBoolean(responseJson, 'useRestrictYN');
                result.closeOnExpired := getJsonBoolean(responseJson, 'closeOnExpired');
                result.unPaidYN := getJsonBoolean(responseJson, 'unPaidYN');
                            
        except on E:Exception do
                raise EPopbillException.Create(-99999999,'결과처리 실패.[Malformed Json]');
        end;

end;

function THometaxCBService.GetJobState ( CorpNum : string; jobID : string) : THometaxCBJobInfo;
begin
        result := GetJobState(CorpNum, jobID, '');
end;


function THometaxCBService.GetJobState ( CorpNum : string; jobID : string; UserID:String) : THometaxCBJobInfo;
var
        responseJson : string;

begin
        if Not ( length ( jobID ) = 18 ) then
        begin
                raise EPopbillException.Create(-99999999, '작업아이디(jobID)가 올바르지 않습니다.');
                exit;
        end;


        responseJson := httpget('/HomeTax/Cashbill/'+ jobID + '/State', CorpNum, UserID);

        result := jsonToHTCashbillJobInfo ( responseJson ) ;
end;

function THometaxCBService.ListActiveState (CorpNum : string) : THomeTaxCBJobInfoList;
begin
        result := ListActiveState(CorpNum, '');
end;


function THometaxCBService.ListActiveState (CorpNum : string; UserID:string) : THomeTaxCBJobInfoList;
var
        responseJson : string;
        jSons : ArrayOfString;
        i : Integer;
begin

        responseJson := httpget('/HomeTax/Cashbill/JobList',CorpNum,UserID);

        if responseJson = '[]' then
        begin
                raise EPopbillException.Create(-99999999, '작업 요청 목록이 존재하지 않습니다.');
                exit;
        end;
        
        try
                jSons := ParseJsonList(responseJson);
                SetLength(result,Length(jSons));

                for i:= 0 to Length(jSons) -1 do
                begin
                        result[i] := jsonToHTCashbillJobInfo(jSons[i]);
                end;

        except on E:Exception do
                raise EPopbillException.Create(-99999999,' 결과처리 실패.[Malformed Json]');
        end;
end;

function THometaxCBService.Search (CorpNum:string; JobID: String; TradeType : Array Of String; TradeUsage : Array Of String; Page: Integer; PerPage : Integer; Order: String) : THomeTaxCBSearchList;
begin
        result := Search(CorpNum, JobID, TradeType, TradeUsage, Page, PerPage, Order, '');
end;


function THometaxCBService.Search (CorpNum:string; JobID: String; TradeType : Array Of String; TradeUsage : Array Of String; Page: Integer; PerPage : Integer; Order: String; UserID:string) : THomeTaxCBSearchList;
var
        responseJson : string;
        uri : String;
        tradeTypeList : String;
        tradeUsageList : String;
        i : integer;
        jSons : ArrayOfString;
begin
        if Not ( length ( jobID ) = 18 ) then
        begin
                raise EPopbillException.Create(-99999999, '작업아이디(jobID)가 올바르지 않습니다.');
                exit;
        end;

        
        for i := 0 to High ( TradeType ) do
        begin
                if TradeType[i] <> '' Then
                tradeTypeList := tradeTypeList + TradeType[i];

                if i <> High(TradeType) then
                tradeTypeList := tradeTypeList + ',';
        end;

        for i := 0 to High ( TradeUsage ) do
        begin
                if TradeUsage[i] <> '' then
                tradeUsageList := tradeUsageList + TradeUsage[i];

                if i <> High(TradeUsage) then
                tradeUsageList := tradeUsageList + ',';
        end;
                            

        if Page < 1 then page := 1;
        if PerPage < 1 then PerPage := 500;

        uri := '/HomeTax/Cashbill/'+jobID;
        uri := uri + '?TradeType=' + tradeTypeList + '&&TradeUsage=' + tradeUsageList;

        uri := uri + '&&Page=' + IntToStr(Page) + '&&PerPage='+ IntToStr(PerPage);
        uri := uri + '&&Order=' + order;

        responseJson := httpget(uri, CorpNum, UserID);
        
        result := THometaxCBSearchList.Create;

        result.code := getJSonInteger(responseJson, 'code');
        result.total := getJSonInteger(responseJson, 'total');
        result.perPage := getJSonInteger(responseJson, 'perPage');
        result.pageNum := getJSonInteger(responseJson, 'pageNum');
        result.pageCount := getJSonInteger(responseJson, 'pageCount');
        result.message := getJSonString(responseJson, 'message');

        try
                jSons := getJsonList(responseJson, 'list');
                SetLength(result.list, Length(jSons));
                for i:=0 to Length(jSons)-1 do
                begin
                        result.list[i] := THometaxCashbill.Create;
                        result.list[i].ntsconfirmNum := getJSonString(jSons[i], 'ntsconfirmNum');
                        result.list[i].tradeDT := getJSonString(jSons[i], 'tradeDT');
                        result.list[i].tradeUsage := getJSonString(jSons[i], 'tradeUsage');
                        result.list[i].tradeType := getJSonString(jSons[i], 'tradeType');
                        result.list[i].supplyCost := getJSonString(jSons[i], 'supplyCost');
                        result.list[i].tax := getJSonString(jSons[i], 'tax');
                        result.list[i].serviceFee := getJSonString(jSons[i], 'serviceFee');
                        result.list[i].totalAmount := getJSonString(jSons[i], 'totalAmount');
                        result.list[i].franchiseCorpNum := getJSonString(jSons[i], 'franchiseCorpNum');
                        result.list[i].franchiseCorpName := getJSonString(jSons[i], 'franchiseCorpName');
                        result.list[i].franchiseCorpType := getJSonInteger(jSons[i], 'franchiseCorpType');
                        result.list[i].identityNum := getJSonString(jSons[i], 'identityNum');
                        result.list[i].identityNumType := getJSonInteger(jSons[i], 'identityNumType');
                        result.list[i].customerName := getJSonString(jSons[i], 'customerName');
                        result.list[i].cardOwnerName := getJSonString(jSons[i], 'cardOwnerName');
                        result.list[i].deductionType := getJSonInteger(jSons[i], 'deductionType');
                end;

        except on E:Exception do
                raise EPopbillException.Create(-99999999,'결과처리 실패.[Malformed Json]');
        end;

end;

function THometaxCBService.RequestJob (CorpNum : string;  queryType:EnumQueryType; SDate: String; EDate: String) : string;
begin
        result := RequestJob(CorpNum, queryType, SDate, EDate, '');
end;


function THometaxCBService.RequestJob (CorpNum : string;  queryType:EnumQueryType; SDate: String; EDate: String; USerID:String) : string;
var
        responseJson : string;

begin
        responseJson := httppost('/HomeTax/Cashbill/'+GetEnumName(TypeInfo(EnumQueryType),integer(queryType))+'?SDate='+SDate+'&&EDate='+EDate, CorpNum, UserID, '', '');
        result := getJsonString(responseJson, 'jobID');

end;

function THometaxCBService.Summary (CorpNum:string; JobID: String; TradeType : Array Of String; TradeUsage : Array Of String) : TCashbillSummary;
begin
        result := Summary(CorpNum, JobID, TradeType, TradeUsage, '');       
end;


function THometaxCBService.Summary (CorpNum:string; JobID: String; TradeType : Array Of String; TradeUsage : Array Of String; UserID: string) : TCashbillSummary;
var
        responseJson : string;
        uri : String;
        tradeTypeList : String;
        tradeUsageList : String;
        i : integer;
begin
        if Not ( length ( jobID ) = 18 ) then
        begin
                raise EPopbillException.Create(-99999999, '작업아이디(jobID)가 올바르지 않습니다.');
                exit;
        end;

        for i := 0 to High ( TradeType ) do
        begin
                if TradeType[i] <> '' Then
                tradeTypeList := tradeTypeList + TradeType[i];

                if i <> High(TradeType) then
                tradeTypeList := tradeTypeList + ',';
        end;

        for i := 0 to High ( TradeUsage ) do
        begin
                if TradeUsage[i] <> '' then
                tradeUsageList := tradeUsageList + TradeUsage[i];

                if i <> High(TradeUsage) then
                tradeUsageList := tradeUsageList + ',';
        end;
                            

            uri := '/HomeTax/Cashbill/'+jobID+'/Summary';
        uri := uri + '?TradeType=' + tradeTypeList + '&&TradeUsage=' + tradeUsageList;
       
        responseJson := httpget(uri, CorpNum, UserID);
        
        result := TCashbillSummary.Create;

        result.count := GetJSonInteger(responseJson, 'count');
        result.supplyCostTotal := GetJSonInteger(responseJson, 'supplyCostTotal');
        result.taxTotal := GetJSonInteger(responseJson, 'taxTotal');
        result.serviceFeeTotal := GetJSonInteger(responseJson, 'serviceFeeTotal');
        result.amountTotal := GetJSonInteger(responseJson, 'amountTotal');
end;

end.
 