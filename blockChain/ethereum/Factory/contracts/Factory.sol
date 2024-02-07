// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./DAO.sol";

contract Factory {
    DAO[] private DAOs;

    // 이 함수는 새로운 DAO 컨트랙트를 생성하고, 생성된 컨트랙트를 DAOs 배열에 추가
    // msg.sender는 컨트랙트를 생성하는 사용자의 주소
    function createContract() public {
        DAO newDAO = new DAO(msg.sender); // 새 DAO 인스턴스 생성
        DAOs.push(newDAO); // 생성된 DAO를 DAOs 배열에 추가
    }

    // 이 수정자는 함수가 받은 인덱스가 DAOs 배열의 길이 내에 있는지 확인
    // 인덱스가 배열의 길이를 초과하면, 함수 실행이 중단
    modifier checkLength(uint index, DAO[] memory _dao) {
        require(index < _dao.length); // 인덱스 유효성 검사
        _; // 수정자를 사용하는 함수의 본문이 이 위치에 삽입
    }

    // 이 함수는 특정 인덱스에 해당하는 DAO 컨트랙트를 반환
    // checkLength 수정자를 사용하여, 요청된 인덱스가 유효한지 먼저 확인
    function getContract(
        uint _index
    ) public view checkLength(_index, DAOs) returns (DAO) {
        return DAOs[_index]; // 요청된 인덱스에 해당하는 DAO 반환
    }
}
