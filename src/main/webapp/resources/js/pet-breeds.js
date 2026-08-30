// 2026-08-13 박유정 — 회원가입·마이페이지 공통 반려동물 품종 목록
var PET_BREEDS = {
    dog: ['골든 리트리버','래브라도 리트리버','비숑 프리제','말티즈','푸들','시바이누','진돗개','포메라니안','치와와','코기','불독','허스키','닥스훈트','슈나우저','믹스견 (모름)'],
    cat: ['코리안숏헤어','페르시안','메인쿤','브리티시숏헤어','러시안블루','스코티시폴드','아비시니안','벵갈','샴','믹스묘 (모름)'],
    etc: ['토끼','햄스터','앵무새','고슴도치','페럿','기니피그','직접 입력']
};

/**
 * kindSelectId: 종류 select의 id (예: pm-kind) 또는 null
 * kindValue:     dog / cat / etc 문자열 (hidden petType 쓸 때)
 * breedSelectId: 품종 select의 id (예: pm-breed, petBreed)
 * selectedBreed: 수정 시 기존 품종 (없으면 null)
 */
function updatePetBreedSelect(kindSelectId, kindValue, breedSelectId, selectedBreed) {
    var kind = kindValue;
    if (kindSelectId) {
        var kindEl = document.getElementById(kindSelectId);
        if (kindEl) kind = kindEl.value;
    }
    var sel = document.getElementById(breedSelectId);
    if (!sel) return;

    if (!kind) {
        sel.innerHTML = '<option value="">종류를 먼저 선택하세요</option>';
        return;
    }

    var list = PET_BREEDS[kind] || [];
    var html = '<option value="">품종 선택</option>';
    for (var i = 0; i < list.length; i++) {
        var b = list[i];
        html += '<option value="' + b + '">' + b + '</option>';
    }
    // 2026/07/11 장우철 — 목록에 없는 기존 품종(예: 예전 가입 자유입력) 유지
    if (selectedBreed && list.indexOf(selectedBreed) < 0) {
        html = '<option value="' + selectedBreed + '">' + selectedBreed + '</option>' + html;
    }
    sel.innerHTML = html;
    if (selectedBreed) sel.value = selectedBreed;
}