def sum_negative_after_removing_extremes(arr):
    """
Возвращает сумму отрицательных элементов, расположенных между
    максимальным и минимальным
    элементами массива (исключая сами эти элементы).
    Если массив пуст или между ними нет элементов, возвращает 0.
    """
    if not arr:
        return 0
    # Находим индексы первого максимума и первого минимума
    idx_max = 0
    idx_min = 0
    for i in range(1, len(arr)):
        if arr[i] > arr[idx_max]:
            idx_max = i
        if arr[i] < arr[idx_min]:
            idx_min = i
    # Суммируем все отрицательные элементы, кроме тех, что стоят на найденных индексах
    total = 0
    for i, val in enumerate(arr):
        if i != idx_max and i != idx_min and val < 0:
            total += val
    return total


# Пример использования с вводом данных
if __name__ == "__main__":
    try:
        n = int(input("Размерность массива N: "))
        if n <= 0:
            print("Размерность может быть только положительной.")
        else:
            print("Введите элементы массива через пробел:")
            a = list(map(int, input().split()))
            if len(a) != n:
                print(f"Ожидалось {n} элементов, получено {len(a)}.")
            else:
                result = sum_negative_after_removing_extremes(a)
                print(f"Сумма отрицательных элементов между максимумом и минимумом: {result}")
    except ValueError:
        print("Ошибка ввода. Введите целые числа.")