// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// DAO 컨트랙트 정의
contract DAO {
    // 컨트랙트 배포자를 저장하는 상태 변수
    address private owner;
    // 멤버 여부를 저장하는 매핑. 주소가 멤버인지 아닌지를 나타냄
    mapping(address => bool) private members;
    // 현재 멤버 수를 저장하는 상태 변수
    uint private memberCount;
    // 제안들을 저장하는 배열
    Proposal[] public proposals;
    // 특정 멤버가 특정 제안에 투표했는지 여부를 저장하는 매핑
    mapping(address => mapping(uint => bool)) private voted;

    // DAO 컨트랙트 생성자
    constructor(address _owner) {
        // 컨트랙트 배포자를 owner 상태 변수에 할당
        owner = _owner;
        // 배포자를 첫 번째 멤버로 추가
        members[_owner] = true;
        // 멤버 수를 1 증가
        memberCount += 1;
    }

    // 제안의 상태를 나타내는 열거형
    enum Play {
        loading, // 준비 중
        start,   // 시작됨
        end      // 종료됨
    }

    // 제안을 나타내는 구조체
    struct Proposal {
        string title; // 제안의 제목
        string text;  // 제안의 내용
        uint votes;   // 투표 수
        Play plays;   // 제안의 상태
        bool execute; // 제안이 실행되었는지 여부
    }

    // 멤버만 호출할 수 있는 함수를 위한 제어자
    modifier onlyMenber() {
        require(members[msg.sender], "no member");
        _;
    }

    // 오직 컨트랙트 소유자만 호출할 수 있는 함수를 위한 제어자
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // 이미 투표한 멤버가 다시 투표하지 못하도록 하는 제어자
    modifier alreadyVote(uint index) {
        require(!voted[msg.sender][index]);
        _;
    }

    // 멤버를 추가하는 함수
    function setghMenbers(address _address) public onlyOwner {
        members[_address] = true; // 멤버로 추가
        memberCount += 1; // 멤버 수 증가
    }

    // 제안을 생성하는 함수
    function createProposal(
        string memory _title,
        string memory _text
    ) public onlyMenber {
        proposals.push(
            Proposal({
                title: _title,
                text: _text,
                votes: 0,
                plays: Play.loading,
                execute: false
            })
        );
    }

    // 제안에 투표하는 함수
    function vote(uint _index) public onlyMenber alreadyVote(_index) {
        Proposal storage proposal = proposals[_index]; // 투표할 제안을 가져옴

        require(proposal.plays == Play.start); // 제안이 시작 상태인지 확인
        proposal.votes += 1; // 투표 수 증가

        voted[msg.sender][_index] = true; // 재투표 방지를 위해 투표 기록
    }

    // 투표를 시작하는 함수
    function startVote(uint _index) public onlyOwner {
        Proposal storage proposal = proposals[_index];
        proposal.plays = Play.start; // 제안의 상태를 시작으로 변경
    }

    // 투표를 종료하는 함수
    function endVote(uint _index) public onlyOwner {
        Proposal storage proposal = proposals[_index];
        require(proposal.plays == Play.start); // 제안이 시작 상태인지 확인
        require(proposal.votes > memberCount / 2); // 과반수 이상이 투표했는지 확인

        proposal.execute = true; // 제안 실행
        proposal.plays = Play.end; // 제안 상태를 종료로 변경
    }
}
