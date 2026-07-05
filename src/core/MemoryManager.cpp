#include "core/MemoryManager.h"

#include <cstdlib>

namespace CineGrade
{

MemoryManager& MemoryManager::Instance()
{
    static MemoryManager instance;
    return instance;
}

void* MemoryManager::Allocate(std::size_t size)
{
    std::lock_guard<std::mutex> lock(m_mutex);

    void* memory = std::malloc(size);

    if (memory != nullptr)
    {
        m_allocatedBytes += size;
        ++m_allocationCount;
    }

    return memory;
}

void MemoryManager::Deallocate(void* ptr)
{
    if (ptr == nullptr)
    {
        return;
    }

    std::lock_guard<std::mutex> lock(m_mutex);
    std::free(ptr);
}

std::size_t MemoryManager::GetAllocatedBytes() const
{
    std::lock_guard<std::mutex> lock(m_mutex);
    return m_allocatedBytes;
}

std::size_t MemoryManager::GetAllocationCount() const
{
    std::lock_guard<std::mutex> lock(m_mutex);
    return m_allocationCount;
}

void MemoryManager::Reset()
{
    std::lock_guard<std::mutex> lock(m_mutex);

    m_allocatedBytes = 0;
    m_allocationCount = 0;
}

}
