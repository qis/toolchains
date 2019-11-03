#pragma once
#if defined(__INTELLISENSE__) && defined(BOOST_ASIO_HAS_CO_AWAIT)
#ifndef BOOST_ASIO_THIS_CORO_HPP
#define BOOST_ASIO_THIS_CORO_HPP
#include <boost/asio/executor.hpp>
#include <experimental/coroutine>
namespace boost::asio::this_coro {
class executor_t {
public:
  constexpr executor_t() noexcept = default;
  constexpr bool await_ready() const noexcept { return true; }
  bool await_suspend(std::experimental::coroutine_handle<> handle) const noexcept { return false; }
  boost::asio::executor await_resume() const noexcept { return {}; }
};
constexpr executor_t executor;
}  // namespace boost::asio::this_coro
#endif
#endif