#pragma once

#include <cstddef>
#include <memory>
#include <mutex>

namespace CineGrade
{

class MemoryManager
{
public:
    static MemoryManager& Instance();

    void* Allocate(std::size_t size);
    void Deallocate(void* ptr);

    std::size_t GetAllocatedBytes() const;
    std::size_t GetAllocationCount() const;

    void Reset();

private:
    MemoryManager() = default;
    ~MemoryManager() = default;

    MemoryManager(const MemoryManager&) = delete;
    MemoryManager& operator=(const MemoryManager&) = delete;

private:
    mutable std::mutex m_mutex;

    std::size_t m_allocatedBytes = 0;
    std::size_t m_allocationCount = 0;
};

}
