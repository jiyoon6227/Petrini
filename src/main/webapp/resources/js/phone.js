/**
 * 휴대전화 입력 공통 (회원가입·회원정보 수정·주문서 배송지)
 * 서버 검사(PhoneNormalizeUtil.isValidMobile)와 같은 규칙
 */

// 숫자만 남기고 최대 11자리, 010-0000-0000 형태로 하이픈 삽입 (입력·붙여넣기 모두 처리)
function formatPhone(value) {
  var digits = String(value || '').replace(/\D/g, '').slice(0, 11);
  if (digits.length < 4) return digits;
  if (digits.length < 8) return digits.slice(0, 3) + '-' + digits.slice(3);
  return digits.slice(0, 3) + '-' + digits.slice(3, 7) + '-' + digits.slice(7);
}

// 010-1234-5678 형식(11자리 휴대전화)인지 확인
function isValidPhone(value) {
  return /^01[016789]-\d{4}-\d{4}$/.test(String(value || ''));
}
