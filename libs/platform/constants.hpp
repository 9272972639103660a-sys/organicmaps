#pragma once

#include <cstdint>

constexpr uint32_t READER_CHUNK_LOG_SIZE = 12;  // 4096 bytes pages
constexpr uint32_t READER_CHUNK_LOG_COUNT =
    14;  // 2^14 = 16384 pages count, hence 64M size cache overall (for data files only)
