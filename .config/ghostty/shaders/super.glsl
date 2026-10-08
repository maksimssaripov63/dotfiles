// ---- 🛸 УЛЬТИМАТИВНЫЙ ГИБРИДНЫЙ ШЕЙДЕР: СКОЛЬЖЕНИЕ + ШЛЕЙФ ----
// Настройки взяты напрямую из ваших файлов
const float DURATION         = 0.35;  // Время скольжения из cursor_glide
const float BG_OPACITY       = 1.0;   // Непрозрачность текста под курсором
const float AA               = 0.0;   // Сглаживание краев курсора
const float SMEAR_BASE_ALPHA = 1;  // Базовая прозрачность хвоста из boo-cursor

// Вспомогательные функции трансформации цвета и координат
vec3 sRGBToLinear(vec3 c) {
    return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(vec3(0.04045), c));
}

float ease(float x) {
    return 1.0 - pow(1.0 - x, 3.0); // Каноничный кубический EaseOut
}

float sdfRect(vec2 p, vec2 center, vec2 halfSize) {
    vec2 d = abs(p - center) - halfSize;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

vec2 rectCenter(vec4 r) {
    return vec2(r.x + r.z * 0.5, r.y - r.w * 0.5);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // 1. Получаем базовую текстуру терминала
    vec4 tex = texture(iChannel0, fragCoord / iResolution.xy);
    fragColor = tex;

    // Защитные проверки фокуса и видимости
    if (iCursorVisible == 0 || iFocus == 0) return;
    if (iCurrentCursorStyle == CURSORSTYLE_BLOCK_HOLLOW || iCurrentCursorStyle == CURSORSTYLE_LOCK) return;

    vec4 cur  = iCurrentCursor;
    vec4 prev = iPreviousCursor;
    if (dot(prev.zw, prev.zw) == 0.0) prev = cur;

    // 2. Рассчитываем общую временную шкалу и прогресс движения
    float t = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0);
    float e = ease(t);

    // 3. Вычисляем текущие сдвинутые координаты скользящего курсора
    vec2 center   = mix(rectCenter(prev), rectCenter(cur), e);
    vec2 halfSize = mix(prev.zw, cur.zw, e) * 0.5;
    vec3 rgb      = sRGBToLinear(mix(iPreviousCursorColor.rgb, iCurrentCursorColor.rgb, e));
    vec4 cursorColor = vec4(rgb, 1.0);

    // Расчет альфа-покрытия для тела скользящего курсора
    float cursorCoverage = 1.0 - smoothstep(0.0, AA, sdfRect(fragCoord, center, halfSize));

    // 4. ГЕНЕРИРУЕМ НЕОНОВЫЙ ШЛЕЙФ КОМЕТЫ (Интеграция логики boo-cursor)
    vec2 moveVec = rectCenter(cur) - rectCenter(prev);
    float moveLength = length(moveVec);
    float trailCoverage = 0.0;
    float smearAlpha = 0.0;

    if (moveLength > 0.1) {
        vec2 moveDir = moveVec / moveLength;
        
        // Задняя кромка шлейфа плавно догоняет курсор по экспоненциальному закону
        float trailFade = exp(-4.5 * t);
        
        // Строим динамический SDF-луч шлейфа от старой позиции до текущей летящей точки
        vec2 startProj = rectCenter(prev);
        vec2 fragToStart = fragCoord - startProj;
        float projLength = dot(fragToStart, moveDir);
        
        // Ограничиваем геометрию шлейфа строго границами движения курсора
        if (projLength > -halfSize.x && projLength < distance(rectCenter(prev), center)) {
            vec2 projPoint = startProj + moveDir * projLength;
            float lateralDist = length(fragCoord - projPoint);
            
            // Проверяем ширину шлейфа, чтобы он не разваливался по бокам ячеек
            if (lateralDist < halfSize.y) {
                // Создаем градиент: 100% у скользящего курсора, 0% в хвосте лага
                float positionAlongLeg = clamp(projLength / moveLength, 0.0, 1.0);
                smearAlpha = SMEAR_BASE_ALPHA * positionAlongLeg * trailFade;
                trailCoverage = 1.0 - smoothstep(0.0, 3.0, lateralDist);
            }
        }
    }

    // 5. КОМПОЗИТИНГ И СМЕШИВАНИЕ СЛОЕВ (Сохраняем буквы поверх блока!)
    float finalCoverage = max(cursorCoverage, trailCoverage * smearAlpha);
    if (finalCoverage <= 0.0) return;

    // Магия сохранения читаемости текста под летящим курсором
    float inTarget = 1.0 - step(0.0, sdfRect(fragCoord, rectCenter(cur), cur.zw * 0.5));
    float text     = smoothstep(min(BG_OPACITY, 0.999), 1.0, tex.a) * inTarget;
    vec4 cursorPixel = mix(cursorColor, tex, text);

    // Выводим итоговый пиксель на экран терминала Ghostty
    fragColor = mix(tex, cursorPixel, finalCoverage);
}

