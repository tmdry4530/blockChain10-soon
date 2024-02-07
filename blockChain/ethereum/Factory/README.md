# 팩토리 컨트랙트

- 스마트 컨트랙트 내에서 다른 컨트랙트를 생성하고 배포하는 기능을 가진 컨트랙트입니다.
- 마치 공장에서 특정 규칙을 따라 제품을 생산하는 것처럼, 정해진 규칙에 따라 새로운 인스턴스(컨트랙트)를 만드는 방식입니다.

- 예시

```javascript
import "./ERC721.sol";

contract FactoryNFT {
    // 이 컨트랙트는 ERC721 토큰 컨트랙트를 생성하는 팩토리 컨트랙트입니다.
    // 'external' 제한자를 사용하여 가스비를 절약하며, 코드 재사용성을 높이고 복잡성을 줄여 추가적인 가스비 절감을 도모합니다.
    // 또한, 상태 변수 접근을 최소화하여 효율성을 높입니다.
    function createContract (string memory _name, string memory _symbol) external {
      // 'new' 키워드를 사용하여 새로운 ERC721 토큰 컨트랙트 인스턴스를 생성합니다.
      ERC721 newNFT = new ERC721(_name, _symbol);

      // 생성된 컨트랙트와 함수 호출자 정보를 포함하는 이벤트를 발생시켜, 트랜잭션 로그를 통해 확인할 수 있습니다.
      emit createEvent(newNFT, msg.sender);
    }

    // 'createEvent' 이벤트는 새로 생성된 컨트랙트 주소와 컨트랙트 생성자의 주소를 기록합니다.
    event createEvent(address indexed _address, address indexed _owner);
}
```

1. 스마트 컨트랙트의 DAO

### DAO란 무엇인가?

DAO는 '분산 자율 조직(Distributed Autonomous Organization)'의 약자로, 중앙 집권식이 아닌 탈중앙화된 방식으로 조직의 규칙을 운영하는 시스템입니다. 이는 스마트 컨트랙트를 통해 구현되며, 조직 내 멤버들의 투표를 통해 의사 결정이 이루어집니다. DAO의 핵심 특징은 분산화, 투명성, 자율성, 저항성으로, 모든 기록은 공개적으로 조회 및 검증이 가능하며, 중앙 집권의 제어 없이 운영됩니다.

### DAO의 장점

DAO의 가장 큰 장점은 중앙 집권식 관리가 없이 조직원들의 투표로 운영된다는 점입니다. 멤버들은 토큰을 통해 거버넌스에 참여할 권리를 가지며, 투표권은 토큰의 양에 따라 결정됩니다. 이를 통해 참여자들은 컨트랙트의 규칙에 따라 제안에 자금을 사용하거나, 제안을 실행하며, 승인 또는 거부를 결정할 수 있습니다.

### DAO의 운영 과정

DAO의 운영 과정은 다음과 같습니다:

- 제안 생성
- 멤버 소집
- 투표 시스템을 통한 제안 투표
- 유예 기간 설정
- 다수결에 따른 제안 실행

2. Factory 컨트랙트 구현

Factory 컨트랙트는 제안을 관리하며, DAO 컨트랙트를 생성 및 관리하는 역할을 합니다. 이를 통해 DAO의 운영 과정이 구현됩니다.

### 컨트랙트 보안 문제: TheDAO 사례

TheDAO 사건은 재진입 공격으로 인해 발생한 보안 문제의 대표적인 예입니다. 공격자는 컨트랙트의 메서드를 예측하지 못한 순서로 재귀적으로 호출하여 이더를 탈취했습니다. 이러한 문제를 방지하기 위해 'checks-effects-interactions' 패턴을 사용하는 것이 좋습니다. 이 패턴은 코드를 검증(checks), 상태 변경(effects), 외부 컨트랙트 호출(interactions)의 순서로 작성하는 디자인 패턴입니다. 이를 통해 재진입 공격을 방지할 수 있습니다.

```javascript
// 'checks-effects-interactions' 패턴을 적용한 은행 및 이자 계산 예제입니다.
// 이 예제에서는 사용자가 이더리움을 입금하고 출금할 수 있는 은행 컨트랙트(myBank)와
// 사용자의 이더리움 잔액에 따라 이자를 계산해주는 이자 계산 컨트랙트(myInterest)를 구현합니다.

import "./myInterest"; // 이자 계산 컨트랙트를 가져옵니다.

// 은행 컨트랙트 정의
contract myBank {
    // 사용자의 이더리움 잔액을 추적합니다.
    mapping(address => uint) balances;
    // 이자 계산을 위해 외부 컨트랙트(myInterest)와 상호작용합니다.
    myInterest _myInterest;

    // 생성자에서 이자 계산 컨트랙트의 주소를 받아 초기화합니다.
    constructor(address _CA){
        _myInterest = myInterest(_CA);
    }

    // 사용자가 이더리움을 입금할 때 호출되는 함수입니다.
    receive() payable {
        // 입금한 사용자의 주소와 금액을 기록합니다.
        balances[msg.sender] += msg.value;
        // 이자 계산 컨트랙트에 입금 정보를 전달합니다.
        _myInterest.setInterest(msg.sender, msg.value);
    }

    // 사용자가 이더리움을 출금할 때 호출되는 함수입니다.
    function ethOut(uint _amount) payable {
        // 출금 전에 사용자의 잔액이 충분한지 검증합니다. (checks)
        require(balances[msg.sender] >= _amount, "잔액 부족");

        // 출금 가능한 경우, 사용자의 잔액을 감소시킵니다. (effects)
        balances[msg.sender] -= _amount;

        // 사용자에게 이더리움을 전송하고, 이자를 받습니다. (interactions)
        address payable(msg.sender).transfer(_amount);
        _myInterest.getInterest(msg.sender);
    }

    // 사용자의 현재 이더리움 잔액을 조회하는 함수입니다.
    function getBalance() public view returns(uint) {
        return balances[msg.sender];
    }
}

// 이자 계산 컨트랙트 정의
contract myInterest {
    // 사용자별 이더리움 입금액을 추적합니다.
    mapping(address => uint) balances;

    // 사용자의 입금액을 기록하여 이자를 계산할 기반을 마련합니다.
    function setInterest(address owner, uint _balance) external {
        balances[owner] += _balance;
    }

    // 사용자에게 이자를 지급하는 함수입니다.
    function getInterest(address owner) external payable {
        // 이자율을 적용하여 이자 금액을 계산합니다.
        uint interest = balances[owner] / 10; // 예시로 10%의 이자율을 적용
        // 계산된 이자를 사용자에게 전송합니다.
        address payable(owner).transfer(interest);
    }
}
```

### 목적 및 개요

- 이 패턴은 스마트 컨트랙트가 외부 컨트랙트를 호출할 때 발생할 수 있는 재진입 공격을 방지하기 위해 사용됩니다. 재진입 공격은 외부 컨트랙트 호출 중에 해당 컨트랙트의 함수가 예상치 못하게 재호출되어 발생하는 보안 취약점입니다.

### 실행 순서

1. 내부 컨트랙트에서 상태변수의 변경을 완료합니다.
2. 변경된 상태를 기반으로 외부 컨트랙트를 호출합니다.

# 뮤텍스 패턴 사용

- 뮤텍스(Mutex) 패턴은 재진입 공격을 방지하기 위한 방법으로, 함수가 재귀적으로 호출되는 것을 막기 위해 사용됩니다. 이 패턴은 함수 실행 중 다른 함수 호출을 방지하는 '잠금' 메커니즘을 구현합니다.
- 구현 방법은 간단하며, bool 타입의 변수를 사용하여 함수의 재호출 가능 여부를 제어합니다. 함수가 실행되기 전에 잠금 상태를 확인하고, 실행 도중에는 잠금을 설정하여 다른 호출을 방지합니다.

```javascript
// myBank 컨트랙트 예시
contract myBank {
    // 사용자의 잔액을 추적하는 매핑
    mapping(address => uint) balances;
    // 재진입 공격을 방지하기 위한 잠금 상태 변수
    bool private lock;

    // 생성자에서 잠금 상태를 초기화합니다.
    constructor(){
        lock = false; // 초기 잠금 상태는 해제됨
    }

    // 사용자가 이더리움을 출금하는 함수
    function ethOut(uint _amount) payable{
        // 잠금 상태를 확인하여 재진입 방지
        require(!lock, "현재 다른 작업이 실행 중입니다.");
        // 사용자의 잔액이 출금하려는 금액보다 많은지 확인
        require(balances[msg.sender] >= _amount, "잔액이 부족합니다.");

        // 잠금 상태를 활성화하여 다른 작업의 실행을 방지
        lock = true;

        // 사용자의 잔액을 감소시키고 이더리움을 전송
        balances[msg.sender] -= _amount;
        address payable(msg.sender).transfer(_amount);

        // 작업이 완료되면 잠금 상태를 해제
        lock = false;
    }
}
```

### 목적 및 방법 요약

- 이 부분은 스마트 컨트랙트가 외부로부터 재귀적인 호출을 받아 재진입 공격을 당하는 것을 방지하는 방법에 대해 설명합니다. 재진입 공격은 외부 컨트랙트가 예상치 못한 시점에 다시 호출되어 발생하는 보안 취약점입니다. 이를 방지하기 위해, 상태 변수를 이용하여 메서드가 이미 실행 중인지를 확인하고, 실행 중이면 다른 호출을 막는 '방지 가드'를 설정합니다.

### 가스비 절약 및 코드 최적화

- 스마트 컨트랙트의 실행 비용을 줄이기 위해 새로운 문법과 조건 논리 제어자(modifier)를 사용합니다. 이를 통해 코드의 재사용성을 높이고, 가스비를 절약할 수 있습니다. 조건 논리 제어자는 특정 조건을 만족할 때만 함수가 실행되도록 하는 역할을 하며, 코드의 중복을 줄여줍니다.

### 구현 방식

- 조건 논리 제어자를 사용하여 함수 실행 전에 특정 조건을 검사합니다. 이를 통해 코드의 안정성을 높이고, 재사용 가능한 조건문을 통해 가스비를 절약할 수 있습니다. 예를 들어, 함수가 특정 사용자에 의해서만 호출될 수 있도록 제한하는 경우, 조건 논리 제어자를 사용하여 이를 간단하게 구현할 수 있습니다.

```javascript
modifier onlyOwner() {
    // 함수를 호출한 사람이 컨트랙트의 소유자인지 확인합니다.
    require(msg.sender == owner, "이 기능은 오직 소유자만 호출할 수 있습니다.");
    // 소유자 확인 후, 실제 함수의 로직이 실행됩니다.
    _; // 이 구문은 modifier를 사용하는 함수의 본문이 이 위치에 삽입됨을 의미합니다.
}

// 가스비 절약을 위해 onlyOwner modifier를 사용하는 함수 예시
function ownerMinting() public onlyOwner {
    // 소유자에게 10000 토큰을 발행합니다.
    _mint(msg.sender, 10000 * (10 ** 18));
}

// 매개변수를 사용하여 특정 주소가 소유자인지 확인하는 modifier 예시
modifier onlyOwner(address _owner){
    // 주어진 주소가 소유자와 일치하는지 확인합니다.
    require(_owner == owner, "이 기능은 오직 소유자만 호출할 수 있습니다.");
    // 확인 후, 실제 함수의 로직이 실행됩니다.
    _; // 이 구문은 modifier를 사용하는 함수의 본문이 이 위치에 삽입됨을 의미합니다.
}

// 매개변수를 사용하는 함수 예시, 특정 주소를 소유자로 확인 후 토큰 발행
function ownerMinting(address sender) public onlyOwner(sender) {
    // 주어진 주소에 10000 토큰을 발행합니다.
    _mint(sender, 10000 * (10 ** 18));
}

```

# DAO의 숙제

- DAO는 탈중앙화 조직의 자유도가 높다.
- 법적인 문제를 통과하는 제안들이지 않기 때문에 법적으로 인정 해주지 않는다.

### 실습 내용

1. factory 컨트랙트(컨트랙트 생성과 생성된 컨트랙트 주소 조회)
2. DAO의 내용 추가(멤버 소집, 제안 내용, 투표 진행, 투표 결과 확인) 여기서는 자금 X

```sh
remixd -s . --remix-ide https://remix.ethereum.org
```

```

```
